<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!-- multipart 방식의 form 값을 처리하기 위해 기본API(request) 대신 외부API를 사용 -->
<%@ page import="com.oreilly.servlet.*" %>
<%@ page import="com.oreilly.servlet.multipart.*" %>
<!-- java.io 패키지의 File 클래스 사용 -->
<%@ page import="java.io.File" %> 
<%@ page import="vo.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.sql.*" %>
<%
	request.setCharacterEncoding("utf-8");

	// 1. 세션 유효성 검사 // 세션값이 없으면 파일 업로드 페이지에 올 수 없다
	if(session.getAttribute("loginMemberId") == null) {
		response.sendRedirect(request.getContextPath()+"/login.jsp");
		return;
	}

	// 2. multipart 셋팅 // multipart form으로 요청된 값은 셋팅 후 받을 수 있음
	// 2-1) 파일 업로드 위치 지정
	// getRealPath() -> 워크스페이스 위치는 언제든 바뀔 수 있기 때문에 코드 실행 시점의 실제 위치를 불러온다
	String dir = request.getServletContext().getRealPath("/upload");
	System.out.println(dir + " <- dir");
	// 2-2) 파일 최대 크기 지정
	int max = 10 * 1024 * 1024;
	// 2-3) request 객체를 MultipartRequest API를 사용할 수 있는 객체로 랩핑해야 한다
	MultipartRequest mRequest = new MultipartRequest(request, dir, max, "utf-8", new DefaultFileRenamePolicy());
	// DefaultFileRenamePolicy() -> 중복되는 이름 뒤에 숫자를 붙여주는 메서드
	
	// 3. 요청값 유효성 검사
	// 3-1) pdf 파일 유효성 검사
	String msg = null;
	if(!mRequest.getContentType("boardFile").equals("application/pdf")) { // 파일 타입이 pdf가 아니면
		System.out.println("pdf 파일이 아닙니다");
		msg = URLEncoder.encode("pdf 파일이 아닙니다", "utf-8");
		// 셋팅(랩핑) 시 이미 저장된(반환된) 파일을 삭제해야 한다
		String saveFilename = mRequest.getFilesystemName("boardFile"); // 저장된 파일 이름을 가져와서
		File f = new File(dir + "\\" + saveFilename); // 저장된 파일의 경로(위치 + 이름)
		/*
			dir을 디버깅해보면 현재 역슬래시(\)를 사용, 자바에서 역슬래시 1개를 표현하기 위해서는 이중으로(\\) 작성하면 해결된다
			하지만 File 클래스가 운영체제를 확인하고 자동으로 맞게 수정해서 반영하기 때문에 "\"를 써도 오류가 발생하지는 않는다 
		*/
		if(f.exists()) {
			f.delete(); // 삭제
			System.out.println(saveFilename + "파일 삭제");
		}
		response.sendRedirect(request.getContextPath()+"/addBoard.jsp?msg=" + msg);
		return;
	}
	
	// 3-2) pdf 파일이 맞으면 MultipartRequest API를 사용하여 문자값 반환받기
	// input type = "text" 값 반환하여 변수에 저장
	String memberId = mRequest.getParameter("memberId");
	String boardTitle = mRequest.getParameter("boardTitle");
	
	System.out.println(memberId + " <- memberId");
	System.out.println(boardTitle + " <- boardTitle");
	
	// Board 객체에 저장 (board 테이블)
	Board board = new Board();
	board.setMemberId(memberId);
	board.setBoardTitle(boardTitle);
	
	// input type = "file" 값은 request 랩핑 시 이미 반환되었다
	// 원본 파일 이름, 저장된 파일 이름, content의 type
	String originFilename = mRequest.getOriginalFileName("boardFile");
	String saveFilename = mRequest.getFilesystemName("boardFile");
	String type = mRequest.getContentType("boardFile");
	
	System.out.println(originFilename + " <- originFilename");
	System.out.println(saveFilename + " <- saveFilename");
	System.out.println(type + " <- type");
	
	// BoardFile 객체에 저장 (board_file 테이블)
	BoardFile boardFile = new BoardFile();
	boardFile.setOriginFilename(originFilename);
	boardFile.setSaveFilename(saveFilename);
	boardFile.setType(type);
	
	// 4. 모델값
	// 드라이버 로딩 및 db 접속
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/fileupload";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);

	// 쿼리 작성
	/*
		1. INSERT INTO board(board_title, member_id, createdate, updatedate) VALUES(?, ?, NOW(), NOW());
		
		2. INSERT INTO board_file(board_no, origin_filename, save_filename, type, path, createdate)
			VALUES(?, ?, ?, ?, 'upload', NOW());
	*/
	
	// 4-1) 첫번째 쿼리 (board 테이블)
	String boardSql = "INSERT INTO board(board_title, member_id, createdate, updatedate) VALUES(?, ?, NOW(), NOW())";
	PreparedStatement boardStmt = conn.prepareStatement(boardSql, PreparedStatement.RETURN_GENERATED_KEYS);
	// RETURN_GENERATED_KEYS -> 방금 insert한 키값을 받아올 수 있다 
	boardStmt.setString(1, board.getBoardTitle());
	boardStmt.setString(2, board.getMemberId());
	boardStmt.executeUpdate();
	// boardNo // 두번째 쿼리 작성 시 필요
	ResultSet keyRs = boardStmt.getGeneratedKeys(); // getGeneratedKeys() 메서드로 키값 호출
	int boardNo = 0;
	if(keyRs.next()) {
		boardNo = keyRs.getInt(1); // 컬럼은 1개이므로 컬럼명을 몰라도 인덱스 사용
	}
	
	// 4-2) 두번째 쿼리 (board_file 테이블)
	String fileSql = "INSERT INTO board_file(board_no, origin_filename, save_filename, type, path, createdate) VALUES(?, ?, ?, ?, 'upload', NOW())";
	PreparedStatement fileStmt = conn.prepareStatement(fileSql);
	fileStmt.setInt(1, boardNo); // getGeneratedKeys()로 받아온 키값 입력
	fileStmt.setString(2, boardFile.getOriginFilename());
	fileStmt.setString(3, boardFile.getSaveFilename());
	fileStmt.setString(4, boardFile.getType());
	fileStmt.executeUpdate();
	
	msg = URLEncoder.encode("파일 업로드 성공!", "utf-8");
	response.sendRedirect(request.getContextPath()+"/boardList.jsp?msg=" + msg);
%>
