<%@page import="java.util.UUID"%>
<%@page import="org.apache.commons.fileupload.FileItem"%>
<%@page import="java.util.List"%>
<%@page import="java.io.File"%>
<%@page import="org.apache.commons.fileupload.disk.DiskFileItemFactory"%>
<%@page import="org.apache.commons.fileupload.servlet.ServletFileUpload"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<%--업로드 된 파일을 처리하자 --%>
	<%
	request.setCharacterEncoding("UTF-8");
	//이래도 한글은 깨진다
	
	
	//파일 전송인지 일반 메세지 전송인지를 판단해 준다
	boolean isMultipart = ServletFileUpload.isMultipartContent(request);
	if (!isMultipart) {//파일 전송이 아니면 폼으로 이동
		response.sendRedirect("uploadForm1.jsp");
		return;
	}
	//여기까지 왔다는 것은 파일 내용이 넘어 왔다는 것
	
	// 1.파일을 받기 위하여 DiskFileItemFactory객체를 생성한다
	DiskFileItemFactory factory = new DiskFileItemFactory();

	// 생략가능
	// 시스템의 임시 폴더를 임시 촐더로 지정한다
	ServletContext servletContext = this.getServletConfig().getServletContext();// 서버 어플리케이션 객체 얻기
	File repository = (File) servletContext.getAttribute("javax.servlet.context.tempdir");//임시 폴더 얻기
	factory.setRepository(repository);//임시 폴더를 지정

	// 2.실제 업로드를 처리하기 위한 ServletFileUpload객체를 생성
	ServletFileUpload upload = new ServletFileUpload(factory);

	// 3.업로드 된 모든 내용을 리스트로 받는다
	List<FileItem> items = upload.parseRequest(request);
	
	//4. 1개씩 처리한다
	if(items != null && items.size() > 0){//데이터가 있다면 ======= 주의
		for(FileItem item : items){// 반복한다
			if (item.isFormField()) {// 일반 폼필드 라면 ========== 폼인지 파일인지 구분
			    String name = item.getFieldName();//필드 네임(name속성 값)
			    String value = item.getString("UTF-8");// 입력값 읽기
			    out.println(name + " : " + value + "<br>");
			}else{//파일이라면
				if(item.getSize() > 0) {// 파일이 넘어왔을때만  파일이 비었느냐
					String fieldName = item.getFieldName();//필드 네임(name속성 값)
				    String fileName = item.getName();//파일 이름
				    //ie(구 인터넷 익스플로러)인 경우 
				    if(fileName.lastIndexOf(File.separator) != -1){//폴더를 구분하는 문자가 있을 경우
				    	//폴더를 구분하는 문자 다음부터 끝까지만 가져온다
				    	fileName = fileName.substring(fileName.lastIndexOf(File.separator) + 1);
				    }
				    
				    String contentType = item.getContentType();// 파일 종류
				    boolean isInMemory = item.isInMemory();//메모리 저장 여부(크면 임시, 적으면 메모리)
				    long sizeInBytes = item.getSize();//파일 크기
				    out.println("fieldName : " + fieldName + "<br>");
				    out.println("fileName : " + fileName + "<br>");
				    out.println("contentType : " + contentType + "<br>");
				    out.println("isInMemory : " + isInMemory + "<br>");
				    out.println("sizeInBytes : " + sizeInBytes + "<br>");
				    
				    String savePath = application.getRealPath("/upload/");
				    String saveFile = UUID.randomUUID().toString();
				    
				    
				    //실제 자신의 폴더로 파일을 옮겨줘야 한다
				    File uploadedFile = new File(savePath + saveFile);//파일객체 만들기
				    item.write(uploadedFile);//저장
				    out.println("저장 : " + saveFile + "<br><hr>");
				}
			}
		}
	}
	%>
	
</body>
</html>