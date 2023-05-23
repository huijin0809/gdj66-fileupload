<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="vo.*" %>
<%
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
			f.save_filename saveFilename,
			f.path path
		FROM board b INNER JOIN board_file f
		ON b.board_no = f.board_no
		ORDER BY b.createdate DESC;
	*/
	String sql = "SELECT b.board_no boardNo, b.board_title boardTitle, b.member_id memberId, b.createdate createdate, b.updatedate updatedate, f.board_file_no boardFileNo, f.origin_filename originFilename, f.save_filename saveFilename, f.path path FROM board b INNER JOIN board_file f ON b.board_no = f.board_no ORDER BY b.createdate DESC";
	PreparedStatement stmt = conn.prepareStatement(sql);
	ResultSet rs = stmt.executeQuery();
	
	// HashMap, ArrayList 사용
	ArrayList<HashMap<String, Object>> list = new ArrayList<>();
	while(rs.next()) {
		HashMap<String, Object> m = new HashMap<>();
		m.put("boardNo", rs.getInt("boardNo"));
		m.put("boardTitle", rs.getString("boardTitle"));
		m.put("memberId", rs.getString("memberId"));
		m.put("createdate", rs.getString("createdate"));
		m.put("updatedate", rs.getString("updatedate"));
		m.put("boardFileNo", rs.getInt("boardFileNo"));
		m.put("originFilename", rs.getString("originFilename"));
		m.put("saveFilename", rs.getString("saveFilename"));
		m.put("path", rs.getString("path"));
		list.add(m);
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>PDF File List</title>
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
	<h1>PDF 자료 목록</h1>
	<div class="red">
		<%	// msg 발생시 출력
			if(request.getParameter("msg") != null) {
		%>
				<%=request.getParameter("msg")%>
		<%
			}
		%>
	</div>
	<%
		// 세션 정보에 따라 분기
		if(session.getAttribute("loginMemberId") != null) {
	%>
			<a href="<%=request.getContextPath()%>/addBoard.jsp">자료 업로드</a>
			<a href="<%=request.getContextPath()%>/logoutAction.jsp">로그아웃</a>
	<%
		} else {
	%>
			<a href="<%=request.getContextPath()%>/login.jsp">로그인</a>
	<%
		}
	%>
	<table>
		<tr>
			<th>memberId</th>
			<th>boardTitle</th>
			<th>originFilename</th>
			<th>createdate</th>
			<th>updatedate</th>
			<th>수정 / 삭제</th>
		</tr>
		<%
			for(HashMap<String, Object> m : list) {
		%>
				<tr>
					<td><%=(String)m.get("memberId")%></td>
					<td><%=(String)m.get("boardTitle")%></td>
					<td>
						<!-- path -> "upload" -->
						<!-- 페이지에 출력은 originFilename으로, 다운로드 시에는 saveFilename으로 -->
						<a href="<%=request.getContextPath()%>/<%=(String)m.get("path")%>/<%=(String)m.get("saveFilename")%>" download="<%=(String)m.get("saveFilename")%>">
							<%=(String)m.get("originFilename")%>
						</a>
					</td>
					<td><%=(String)m.get("createdate")%></td>
					<td><%=(String)m.get("updatedate")%></td>
					<td>
						<!-- 세션 정보가 일치할 때만 수정 / 삭제 버튼 출력 -->
						<% 
							if(session.getAttribute("loginMemberId") != null) {
								// 세션 값 불러오기
								String loginId = (String)session.getAttribute("loginMemberId");
								// 세션 정보가 일치하는지 확인
								if(loginId.equals((String)m.get("memberId"))) {
						%>
									<a href="<%=request.getContextPath()%>/modifyBoard.jsp?boardNo=<%=m.get("boardNo")%>&boardFileNo=<%=m.get("boardFileNo")%>">
										수정
									</a>
									/
									<a href="<%=request.getContextPath()%>/removeBoard.jsp?boardNo=<%=m.get("boardNo")%>&boardFileNo=<%=m.get("boardFileNo")%>">
										삭제
									</a>
						<%
								}
								
							}
						%>
					</td>
				</tr>
		<%
			}
		%>
	</table>
</body>
</html>