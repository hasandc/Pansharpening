;+
; FILENAME:
;    dot_product.pro
; PURPOSE:
;    ----------
;    To perform dot product calculation on two distinct 3-dimentional data. 
;    
; INPUT:
;    - A, B           A 3-dimensional image data of data A and B.
;
; OUTPUT:
;    - SUM_XY         The dot product of A and B.
;
; USAGE:
;       ENVI> x = DOT_PRODUCT(A, B)
;
; REVISION HISTORY:
;    2019-Sept-30  H.Cahyono
;                  Initial coding.
;-

function DOT_PRODUCT, a, b
  dim_a = SIZE(a)
  sum_xy = MAKE_ARRAY(dim_a[1], dim_a[2], value=0.0)
  for i=0, dim_a[1]-1 do begin
    for j=0, dim_a[2]-1 do begin
      x = REFORM(DOUBLE(a[i, j, *]), dim_a[3])
      y = REFORM(DOUBLE(b[i, j, *]), dim_a[3])
      x_dot_y = TRANSPOSE(x) # y
      sum_xy[i, j] = TOTAL(x_dot_y)
    endfor
  endfor

  RETURN, sum_xy
end
