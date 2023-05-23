<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!-- multipart 방식의 form 값을 처리하기 위해 기본API(request) 대신 외부API를 사용 -->
<%@ page import="com.oreilly.servlet.*" %>
<%@ page import="com.oreilly.servlet.multipart.*" %>
<!-- java.io 패키지의 File 클래스 사용 -->
<%@ page import="java.io.File" %> 
<%@ page import="java.sql.*" %>
<%@ page import="java.net.*" %>
<%@ page import="vo.*"%>
<%
	// 1. 세션 유효성 검사 // 세션값이 없으면 파일 수정 페이지에 올 수 없다
	if(session.getAttribute("loginMemberId") == null) {
		response.sendRedirect(request.getContextPath()+"/login.jsp");
		return;
	}

	// 2. multipart 셋팅
	String dir = request.getServletContext().getRealPath("/upload");
	int max = 10 * 1024 * 1024;
	MultipartRequest mRequest = new MultipartRequest(request, dir, max, "utf-8", new DefaultFileRenamePolicy());
	// 변수에 값 저장
	int boardFileNo = Integer.parseInt(mRequest.getParameter("boardFileNo"));
	int boardNo = Integer.parseInt(mRequest.getParameter("boardNo"));
	String boardTitle = mRequest.getParameter("boardTitle");
	
	// 3. 모델값
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/fileupload";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// 3-1) boardTitle 수정
	String boardSql = "UPDATE board SET board_title = ?, updatedate = NOW() WHERE board_no = ?";
	PreparedStatement boardStmt = conn.prepareStatement(boardSql);
	boardStmt.setString(1, boardTitle);
	boardStmt.setInt(2, boardNo);
	int boardRow = boardStmt.executeUpdate();
	if(boardRow == 1) {
		System.out.println(boardRow + " <- boardTitle 수정 성공");
	} else {
		System.out.println(boardRow + " <- boardTitle 수정 실패");
	}
	
	// 3-2) boardFile 수정 // 기존 boardFile는 테이블에서 삭제, 새로운 boardFile를 테이블에 추가
	String msg = null;
	System.out.println(mRequest.getOriginalFileName("boardFile"));
	if(mRequest.getOriginalFileName("boardFile") != null) { // null이 아니면 수정할 파일이 존재
		// 수정할 파일이 (이미 업로드 된 상태이므로) pdf 파일인지 유효성 검사
		// pdf 파일이 아니면, 새로 업로드한 파일을 삭제해야 한다
		if(!mRequest.getContentType("boardFile").equals("application/pdf")) {
			System.out.println("pdf 파일이 아닙니다");
			msg = URLEncoder.encode("pdf 파일이 아닙니다", "utf-8");
			// 새로 저장된(반환된) 파일을 삭제하기 위해
			String saveFilename = mRequest.getFilesystemName("boardFile"); // 저장된 파일 이름을 가져와서
			File f = new File(dir + "/" + saveFilename); // 저장된 파일의 경로(위치 + 이름)
			if(f.exists()) {
				f.delete(); // 삭제
				System.out.println(saveFilename + "파일 삭제");
			}
			response.sendRedirect(request.getContextPath()+"/modifyBoard.jsp?boardNo="+boardNo+"&boardFileNo="+boardFileNo+"&msg="+msg);
			return;
		} else { // pdf 파일이 맞으면, 이전 파일을 삭제(delete) 후 db 수정(update)
			String type = mRequest.getContentType("boardFile");
			String originFilename = mRequest.getOriginalFileName("boardFile");
			String saveFilename = mRequest.getFilesystemName("boardFile");
			// Vo 타입에 저장
			BoardFile boardFile = new BoardFile();
			boardFile.setBoardFileNo(boardFileNo);
			boardFile.setType(type);
			boardFile.setOriginFilename(originFilename);
			boardFile.setSaveFilename(saveFilename);
			
			// 1) 이전 파일 삭제 (delete)
			String saveFilenameSql = "SELECT save_filename FROM board_file WHERE board_file_no = ?";
			PreparedStatement saveFilenameStmt = conn.prepareStatement(saveFilenameSql);
			saveFilenameStmt.setInt(1, boardFile.getBoardFileNo());
			ResultSet saveFilenameRs = saveFilenameStmt.executeQuery();
			String preSaveFilename = null;
			if(saveFilenameRs.next()) {
				preSaveFilename = saveFilenameRs.getString("save_filename");
			}
			File f = new File(dir + "/" + preSaveFilename);
			if(f.exists()) {
				f.delete();
			}
			
			// 2) db 수정 (update)
			String boardFileSql = "UPDATE board_file SET origin_filename = ?, save_filename = ? WHERE board_file_no = ?";
			PreparedStatement boardFileStmt = conn.prepareStatement(boardFileSql);
			boardFileStmt.setString(1, boardFile.getOriginFilename());
			boardFileStmt.setString(2, boardFile.getSaveFilename());
			boardFileStmt.setInt(3, boardFile.getBoardFileNo());
			int boardFileRow = boardFileStmt.executeUpdate();
			if(boardFileRow == 1) {
				System.out.println(boardFileRow + " <- boardFile 수정 성공");
			} else {
				System.out.println(boardFileRow + " <- boardFile 수정 실패");
			}
		}
	}
	msg = URLEncoder.encode("정상적으로 수정되었습니다", "utf-8");
	response.sendRedirect(request.getContextPath()+"/boardList.jsp?msg=" + msg);
%>