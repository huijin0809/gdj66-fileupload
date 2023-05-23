<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vo.*" %>
<%
	// 유효성 검사 // 세션값이 없으면 파일 업로드 페이지에 올 수 없다
	if(session.getAttribute("loginMemberId") == null) {
		response.sendRedirect(request.getContextPath()+"/login.jsp");
		return;
	}
	// null이 아니면 세션 정보 받아오기
	String loginId = (String)session.getAttribute("loginMemberId");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>add board + file</title>
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
	<h1>자료실</h1>
	<h3>pdf 파일만 업로드 가능합니다</h3>
	<div class="red">
		<%	// msg 발생시 출력
			if(request.getParameter("msg") != null) {
		%>
				<%=request.getParameter("msg")%>
		<%
			}
		%>
	</div>
	<form action="<%=request.getContextPath()%>/addBoardAction.jsp" enctype="multipart/form-data" method="post">
	<!-- multipart form의 method는 post 방식 사용 -->
		<table>
			<!-- 현재 로그인한 사용자 아이디 (세션정보), 수정불가 -->
			<tr>
				<th>memberId</th>
				<td>
					<input type="text" name="memberId" value="<%=loginId%>" readonly>
				</td>
			</tr>
			<!-- 게시글 제목 -->
			<tr>
				<th>boardTitle</th>
				<td>
					<textarea rows="3" cols="50" name="boardTitle" required></textarea>
					<!-- required : 값을 입력하지 않으면(null) submit할 수 없음, 공백은 넘어감! -->
				</td>
			</tr>
			<!-- 파일 업로드 -->
			<tr>
				<th>boardFile</th>
				<td>
					<input type="file" name="boardFile" required>
					<!-- required : 값을 입력하지 않으면(null) submit할 수 없음 -->
				</td>
			</tr>
		</table>
		<a href="<%=request.getContextPath()%>/boardList.jsp">뒤로가기</a>
		<button type="submit">자료 업로드</button>
	</form>
</body>
</html>