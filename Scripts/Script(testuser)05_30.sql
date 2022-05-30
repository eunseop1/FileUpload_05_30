-- 부서별 급여 합계 순위
SELECT 
   DEPT_CODE , EMP_ID , sum(SALARY),
   rank() OVER (PARTITION BY GROUPING(DEPT_CODE), GROUPING (EMP_ID) ORDER BY SUM(SALARY) DESC) 순위
FROM 
   temp
GROUP BY 
   ROLLUP(DEPT_CODE, EMP_ID);
-- 문제] sale_hits의 자료를 이용하여 일자별 매출 순위와 순위별 사업장 품목을 보여라!!!!
SELECT * FROM SALE_HIST sh;

SELECT 
	sh.*, RANK() OVER(PARTITION BY sale_date ORDER BY sale_amt desc) 순위
FROM 
	SALE_HIST sh;

-- CUME_DIST, PERCENT_RANK, NTILE(N), ROW_NUMBER()
SELECT
	EMP_ID, EMP_NAME ,SALARY ,
	RANK () over(ORDER BY SALARY desc) 순위1,
	CUME_DIST () over(ORDER BY SALARY desc) 순위2, -- 순위를 0 ~ 1 사이의 실수로 표시
	count(SALARY) OVER (ORDER BY SALARY RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) 순위3
FROM 
	TEMP;
--
SELECT 
   EMP_ID , EMP_NAME , SALARY ,
   rank() OVER (ORDER BY SALARY ) 순위1,         -- 순위를 자연수로 표시
   CUME_DIST() OVER (ORDER BY SALARY ) 순위2,      -- 순위를 0~1사이의 실수로 표시
   PERCENT_RANK() OVER (ORDER BY SALARY)  순위3,   -- 퍼센트
   NTILE(5) OVER (ORDER BY SALARY ) 순위4,         -- n개의 그룹으로 나눈다.
   ROW_NUMBER() OVER (ORDER BY SALARY ) 순위5      -- 파티션 내의 실행된 ROW 순서의 일련번호
FROM 
   TEMP;

-- 입사연도별 급여의 합계를 구하라
SELECT
	SUBSTR(EMP_ID, 1, 4), SUM(SALARY) 
FROM
	TEMP t 
GROUP BY
	SUBSTR(EMP_ID, 1, 4); 

-- 임사연도별 차례대로 전부 급여의 합계를 구하라
SELECT
	SUBSTR(EMP_ID, 1, 4), EMP_ID , EMP_NAME , SUM(SALARY) 
FROM
	TEMP t 
GROUP BY
	SUBSTR(EMP_ID, 1, 4), EMP_ID , EMP_NAME
ORDER BY
	1;

-- 순위를 구하고 싶다. rank빼고는 다른건 별 쓸모가 없어보인다
SELECT
	SUBSTR(EMP_ID, 1, 4), EMP_ID , EMP_NAME , SUM(SALARY), 
	RANK() over(PARTITION BY SUBSTR(EMP_ID, 1, 4) ORDER BY SALARY) RANK순위1,
	CUME_DIST() over(PARTITION BY SUBSTR(EMP_ID, 1, 4) ORDER BY SALARY) CUME_DIST순위2,
	PERCENT_RANK() over(PARTITION BY SUBSTR(EMP_ID, 1, 4) ORDER BY SALARY) PERCENT_RANK순위3,
	NTILE(2) over(PARTITION BY SUBSTR(EMP_ID, 1, 4) ORDER BY SALARY) NTILE순위4,
	ROW_NUMBER() over(PARTITION BY SUBSTR(EMP_ID, 1, 4) ORDER BY SALARY) ROW_NUMBER순위5
FROM
	TEMP t 
GROUP BY
	SUBSTR(EMP_ID, 1, 4), EMP_ID , EMP_NAME, SALARY;

-- SALE_HITS의 자료를 이용하여 '01' 사업장의 품목별 당일 판매액과 
-- 당일까지의 누적 판매액을 구하는 쿼리
SELECT
	sh.*, SUM(sale_amt) OVER(PARTITION BY sale_item ORDER BY sale_item ROWS UNBOUNDED PRECEDING) 누계 
FROM
	sale_HIST sh
WHERE
	sale_site = '01'
ORDER BY
	sale_item, sale_DATE;



-- 가장 간단한 형태의 익명 프로시져!!!
BEGIN
	dbms_output.put_line('Hello PL/SQL!!!');
END;-- end에서 실행시켜야 한다

BEGIN
	FOR cnt IN 1..10 LOOP -- 1부터 10까지의 합
		dbms_output.put_line('Hello PL/SQL!!!');
	end LOOP;	
END;

-- 1부터 100까지 합
DECLARE --선언부
	vsum NUMBER := 0;
BEGIN 
	FOR cnt IN 1..100 LOOP -- 1부터 10까지의 합
		vsum := vsum + cnt;
	end LOOP;
	dbms_output.put_Line('1~100까지 합:' || vsum);
END;

-- ===================================================================================
-- 사원 정보를 저장하는 프로시져를 만들어 보자
-- ===================================================================================
-- 사번,이름,연봉만 저장하는 임시테이블을 만들어서 작업해보자
CREATE TABLE emp2 AS SELECT EMP_ID id, EMP_NAME name, SALARY sal  FROM TEMP t ;
SELECT * FROM emp2;

CREATE OR REPLACE PROCEDURE insert_emp2(
	vid IN NUMBER, -- in은 입력변수
	vname IN varchar2,
	vsal IN NUMBER
)
IS 
BEGIN 
	INSERT INTO emp2 VALUES (vid, vname, vsal);
	COMMIT;
	DBMS_OUTPUT.PUT_LINE('사번: ' || vid);
	DBMS_OUTPUT.PUT_LINE('이름: ' || vname);
	DBMS_OUTPUT.PUT_LINE('연봉: ' || vsal);
	DBMS_OUTPUT.PUT_LINE('저장 성공 !!!');
END;

-- 프로시져 호출
DELETE FROM emp2; -- 모두 삭제
CALL INSERT_EMP2(20200501, '나그네', 56789000); -- INSERT 대신 이것만 실행해도 저장된다
SELECT * FROM emp2;

--지정 사번의 연봉을 10% 인상하는 프로시져를 작성해보자
CREATE OR REPLACE PROCEDURE update_sal(
	vid IN number
)
IS
BEGIN
	UPDATE emp2 SET sal = sal * 1.1 WHERE id = vid;
END;

SELECT * FROM emp2;
CALL UPDATE_SAL(20200501); 

CALL INSERT_EMP2(20200502, '나사람', 34567800) ;
CALL UPDATE_SAL(20200502); 

--사번과 인상률을 인수로 받아 연봉을 변경하도록 바꿔보자
CREATE OR REPLACE PROCEDURE update_sal(
	vid IN NUMBER,
	vrate IN NUMBER 
)
IS
BEGIN
	UPDATE emp2 SET sal = sal * (1 + vrate) WHERE id = vid;
END; 
SELECT * FROM emp2;
CALL UPDATE_SAL(20200501,0.5); 
-- SQL 전용 클라이언트에서 프로시져를 호출하는 방법
-- EXECUTE update_sal(20200501, 0.5);

-- 프로시져와 함수의 차이는 리턴값이 있느냐 여부. 리턴 값이 있으면 function이라 한다
--사번과 인상률을 인수로 받아 연봉을 변경하고 변경된 연봉을 돌려주는 함수를 만들어 보자
CREATE OR REPLACE FUNCTION update_sal_fn(
	vid IN NUMBER,
	vrate IN NUMBER 
)
RETURN NUMBER
IS
	vsal emp2.sal%TYPE
BEGIN
	UPDATE emp2 SET sal = sal * (1 + vrate) WHERE id=vid;
	--변경된 연봉을 변수에 저장한다
	SELECT sal INTO vsal FROM emp2 WHERE id = vid;
	--변경된 연봉을 알려준다
	RETURN vsal;
END;


-- 함수는 select 명령으로 실행한다
SELECT update_sal_fn(20200501, 0.2) "인상된 연봉" FROM dual;




























