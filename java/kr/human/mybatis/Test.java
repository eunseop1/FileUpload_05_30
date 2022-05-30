package kr.human.mybatis;

import java.io.File;

public class Test {
	public static void main(String[] args) {
		System.out.println(File.separator);
		System.out.println(File.pathSeparator);
		System.out.println("D:\\eclipse\\workspace\\.metadata\\.plugins\\org.eclipse.wst.server.core\\tmp0\\wtpwebapps\\FileUpload_05-30\\upload\\로그인되었습니다..png".lastIndexOf("file.separator"));
		System.out.println("로그인되었습니다..png".lastIndexOf("file.separator"));
	}
}
