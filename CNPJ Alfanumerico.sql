create or replace FUNCTION f_valida_cnpj_alfanumerico (p_cnpj IN VARCHAR2)
   RETURN VARCHAR2
IS
   TYPE array_dv IS VARRAY(2) OF PLS_INTEGER;

   v_array_dv    array_dv := array_dv(0,0);
   v_cnpj_string VARCHAR2(14);
   total         NUMBER   := 0;
   coeficiente   NUMBER   := 0;
   dv1           NUMBER   := 0;
   dv2           NUMBER   := 0;
   digito        NUMBER   := 0;
   j             INTEGER;
   i             INTEGER;
   vboolean      BOOLEAN;
BEGIN

   IF LENGTH(p_cnpj) <> 14 AND LENGTH(p_cnpj) <> 18 THEN
      return 'False';
   END IF;

   IF LENGTH(p_cnpj) = 18 AND ((substr(p_cnpj,3,1) <> '.') OR (substr(p_cnpj,7,1) <> '.') OR (substr(p_cnpj,11,1) <> '/') OR (substr(p_cnpj,16,1) <> '-')) THEN
      return 'False';
   END IF; 

   -- retira mascara, se tiver --
   v_cnpj_string := REGEXP_REPLACE(p_cnpj, '[^0-9A-Z]');

   IF LENGTH(v_cnpj_string) = 14 THEN
      total := 0;
   ELSE
      return 'False';
   END IF;

   dv1 := TO_NUMBER(SUBSTR(v_cnpj_string,LENGTH(v_cnpj_string) - 1, 1 ));
   dv2 := TO_NUMBER(SUBSTR(v_cnpj_string,LENGTH(v_cnpj_string), 1 ));

   v_array_dv( 1 ) := 0;
   v_array_dv( 2 ) := 0;

   FOR j IN 1 .. 2
   LOOP
      total := 0;
      coeficiente := 2;

      FOR i IN REVERSE 1 ..((LENGTH(v_cnpj_string) - 3) + j)
      LOOP
         Begin
           digito := TO_NUMBER( SUBSTR( v_cnpj_string, i, 1 ));
         Exception 
           when others then
             -- valor de calculo p/Alfanumerico
             digito := TO_NUMBER(ascii(SUBSTR( v_cnpj_string, i, 1 ))-48);
             --
         End;
         total  := total + (digito * coeficiente);
         coeficiente := coeficiente + 1;

         IF (coeficiente > 9) THEN
            coeficiente := 2;
         END IF;
      END LOOP;

      v_array_dv(j) := 11 - MOD(total,11);

      -- Caso o resto da divisão seja menor que 2, o dv é zero
      IF (v_array_dv(j) >= 10) THEN
         v_array_dv(j) := 0;
      END IF;
   END LOOP;

   vboolean := (dv1 = v_array_dv(1)) AND (dv2 = v_array_dv(2));

   if vboolean then return 'True'; else return 'False'; end if;

END;
