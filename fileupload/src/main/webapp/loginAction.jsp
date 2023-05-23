<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.net.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="vo.*" %>
<%
	// 1. 유효성 검사
	// 세션정보
	if(session.getAttribute("loginMemberId") != null) {
		response.sendRedirect(request.getContextPath()+"/boardList.jsp");
		return;
	}
	// memberId, memberPw
	String msg = null;
	if(request.getParameter("memberId") == null
			|| request.getParameter("memberId").equals("")) {
		msg = URLEncoder.encode("아이디를 입력해주세요", "utf-8");
	} else if (request.getParameter("memberPw") == null
			|| request.getParameter("memberPw").equals("")) {
		msg = URLEncoder.encode("비밀번호를 입력해주세요", "utf-8");
	}
	if(msg != null) {
		response.sendRedirect(request.getContextPath()+"/login.jsp?msg=" + msg);
		return;
	}
	String memberId = request.getParameter("memberId");
	String memberPw = request.getParameter("memberPw");
	
	// 2. 모델값
	// 드라이버 로딩 및 db 접속
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/fileupload";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// 2-1) 회원정보 조회
	String sql = "SELECT count(*) FROM member WHERE member_id = ? AND member_pw = PASSWORD(?)";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setString(1, memberId);
	stmt.setString(2, memberPw);
	ResultSet rs = stmt.executeQuery();
	// 모델값을 변수에 저장
	int cnt = 0;
	if(rs.next()) {
		cnt = rs.getInt(1);
	}
	
	// 2-2) 입력한 정보가 존재하면 (cnt가 1이면) 세션에 저장
	if(cnt == 1) {
		System.out.println("로그인 성공");
		session.setAttribute("loginMemberId", memberId); // 세션에 아이디 저장
		response.sendRedirect(request.getContextPath() + "/boardList.jsp");
		return;
	} else {
		System.out.println("로그인 실패");
		msg = URLEncoder.encode("로그인에 실패하였습니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/login.jsp?msg=" + msg);
		return;
	}
%>