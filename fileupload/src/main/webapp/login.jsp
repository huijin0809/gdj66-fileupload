<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	// 유효성 검사 // 세션값이 존재하면 로그인 페이지에 올 수 없다
	if(session.getAttribute("loginMemberId") != null) {
		response.sendRedirect(request.getContextPath()+"/boardList.jsp");
		return;
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>login here</title>
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
	<h1>로그인</h1>
	<div class="red">
		<%	// msg 발생시 출력
			if(request.getParameter("msg") != null) {
		%>
				<%=request.getParameter("msg")%>
		<%
			}
		%>
	</div>
	<form action="<%=request.getContextPath()%>/loginAction.jsp" method="post">
		<table>
			<tr>
				<th>아이디</th>
				<td>
					<input type="text" name="memberId">
				</td>
			</tr>
			<tr>
				<th>비밀번호</th>
				<td>
					<input type="password" name="memberPw">
				</td>
			</tr>
		</table>
		<a href="<%=request.getContextPath()%>/boardList.jsp">뒤로가기</a>
		<button type="submit">로그인</button>
	</form>
</body>
</html>