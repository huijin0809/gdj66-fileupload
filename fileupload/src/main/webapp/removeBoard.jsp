<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%
	// 1. 유효성 검사 // 세션값이 없으면 파일 업로드 페이지에 올 수 없다
	// 1-1) 세션
	if(session.getAttribute("loginMemberId") == null) {
		response.sendRedirect(request.getContextPath()+"/login.jsp");
		return;
	}
	
	// 1-2) 요청값
	if(request.getParameter("boardNo") == null
			|| request.getParameter("boardNo").equals("")
			|| request.getParameter("boardFileNo") == null
			|| request.getParameter("boardFileNo").equals("")) {
		response.sendRedirect(request.getContextPath()+"/boardList.jsp");
		return;
	}
	// null이 아니면 변수에 값 저장
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	int boardFileNo = Integer.parseInt(request.getParameter("boardFileNo"));

	// 2. 모델값
	// 드라이버 로딩 및 db 접속
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/fileupload";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// 쿼리 작성 inner join
	/*
		SELECT
			b.board_no boardNo,
			b.board_title boardTitle,
			b.member_id memberId,
			b.createdate createdate,
			b.updatedate updatedate,
			f.board_file_no boardFileNo,
			f.origin_filename originFilename,
			f.save_filename saveFilename
		FROM board b INNER JOIN board_file f
		ON b.board_no = f.board_no
		WHERE b.board_no = ? AND f.board_file_no = ?;
	*/
	String sql = "SELECT b.board_no boardNo, b.board_title boardTitle, b.member_id memberId, b.createdate createdate, b.updatedate updatedate, f.board_file_no boardFileNo, f.origin_filename originFilename, f.save_filename saveFilename FROM board b INNER JOIN board_file f ON b.board_no = f.board_no WHERE b.board_no = ? AND f.board_file_no = ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1, boardNo);
	stmt.setInt(2, boardFileNo);
	ResultSet rs = stmt.executeQuery();
	
	// HashMap 사용
	HashMap<String, Object> map = null;
	if(rs.next()) {
		map = new HashMap<String, Object>();
		map.put("boardNo", rs.getInt("boardNo"));
		map.put("boardTitle", rs.getString("boardTitle"));
		map.put("memberId", rs.getString("memberId"));
		map.put("createdate", rs.getString("createdate"));
		map.put("updatedate", rs.getString("updatedate"));
		map.put("boardFileNo", rs.getInt("boardFileNo"));
		map.put("originFilename", rs.getString("originFilename"));
		map.put("saveFilename", rs.getString("saveFilename"));
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>remove Board</title>
<style>
	table, th, td {
		border: 1px solid #000000;
	}
	table {
		border-collapse: collapse;
	}
	.red {
		color:red;
	}
</style>
</head>
<body>
	<h1>board & boardFile 삭제</h1>
	<div class="red">
		<%	// msg 발생시 출력
			if(request.getParameter("msg") != null) {
		%>
				<%=request.getParameter("msg")%>
		<%
			}
		%>
		정말 삭제하시겠습니까?
	</div>
	<form action="<%=request.getContextPath()%>/removeBoardAction.jsp" method="post">
		<input type="hidden" name="boardNo" value="<%=map.get("boardNo")%>">
		<input type="hidden" name="boardFileNo" value="<%=map.get("boardFileNo")%>">
		<input type="hidden" name="saveFilename" value="<%=map.get("saveFilename")%>">
		<!-- 파일 삭제를 위해 저장된 파일명도 넘긴다 -->
		<table>
			<tr>
				<th>memberId</th>
				<td>
					<input type="text" name="memberId" value="<%=map.get("memberId")%>" readonly>
					<!-- 유효성 검사를 위해 memberId 값도 넘긴다 -->
				</td>
			</tr>
			<tr>
				<th>boardTitle</th>
				<td>
					<%=map.get("boardTitle")%>
				</td>
			</tr>
			<tr>
				<th>boardFile</th>
				<td class="red">
					<%=map.get("originFilename")%>
				</td>
			</tr>
			<tr>
				<th>createdate</th>
				<td><%=map.get("createdate")%></td>
			</tr>
			<tr>
				<th>updatedate</th>
				<td><%=map.get("updatedate")%></td>
			</tr>
		</table>
		<a href="<%=request.getContextPath()%>/boardList.jsp">뒤로가기</a>
		<button type="submit">삭제</button>
	</form>
</body>
</html>