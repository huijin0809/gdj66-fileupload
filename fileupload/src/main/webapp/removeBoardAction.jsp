<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!-- java.io 패키지의 File 클래스 사용 -->
<%@ page import="java.io.File" %> 
<%@ page import="java.sql.*" %>
<%@ page import="java.net.*" %>
<% 
	// 한글 깨지지 않게 인코딩
	request.setCharacterEncoding("utf-8");

	// 1. 유효성 검사
	// 세션정보 // 세션값이 없으면 파일 삭제 페이지에 올 수 없다
	if(session.getAttribute("loginMemberId") == null) {
		response.sendRedirect(request.getContextPath()+"/login.jsp");
		return;
	}
	String loginId = (String)session.getAttribute("loginMemberId");
	// 요청값이 null인지 // 작성자와 세션정보가 일치하는지 확인
	if(request.getParameter("boardNo") == null
			|| request.getParameter("boardFileNo") == null
			|| request.getParameter("saveFilename") == null
			|| request.getParameter("memberId") == null
			|| !request.getParameter("memberId").equals(loginId)) {
		response.sendRedirect(request.getContextPath()+"/boardList.jsp");
		return;
	}
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	int boardFileNo = Integer.parseInt(request.getParameter("boardFileNo"));
	String saveFilename = request.getParameter("saveFilename");
	String memberId = request.getParameter("memberId");
	
	// 2. 모델값
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/fileupload";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	// 2-1) 파일 삭제
	String dir = request.getServletContext().getRealPath("/upload"); // 파일 저장 위치 지정
	File f = new File(dir + "/" + saveFilename); // 저장된 파일의 경로(위치 + 이름)
	if(f.exists()) {
		f.delete(); // 삭제
		System.out.println(saveFilename + "파일 삭제");
	}
	// 2-2) 게시글 삭제 (db 수정)
	String sql = "DELETE FROM board WHERE board_no = ?"; // DELETE시 CASCADE 설정이 되어있으므로 board_file은 자동으로 삭제된다
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1, boardNo);
	int row = stmt.executeUpdate();
	String msg = null;
	if(row == 1) {
		System.out.println(row + " <- board 삭제 성공");
		msg = URLEncoder.encode("정상적으로 삭제되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/boardList.jsp?msg=" + msg);
		return;
	} else {
		System.out.println(row + " <- board 삭제 실패");
		msg = URLEncoder.encode("삭제되지 않았습니다 다시 시도해주세요", "utf-8");
		response.sendRedirect(request.getContextPath()+"/removeBoard.jsp?msg=" + msg + "&boardNo=" + boardNo + "&boardFileNo=" + boardFileNo);
		return;
	}
%>