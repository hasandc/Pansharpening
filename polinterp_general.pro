;+
; FILENAME:
;    polinterp_general.pro
; PURPOSE:
;    ----------
;    An image interpolation using a general polynomial interpolator.
;    
; INPUT:
;    - IMG            A reference image (2-D or 3-D);
;    - RATIO          Scalling ratio - the value should be at the power of two;
;
; OUTPUT:
;    - i1lru          An interpolated image.
;
; USAGE:
;       ENVI> A = POLINTERP_GENERAL(IMG, RATIO)
;
; REVISION HISTORY:
;    2019-Sept-30  H.Cahyono
;                  Initial coding.
;-

function POLINTERP_GENERAL, img, ratio
  ; Image interpolator by using a general polinomial interpolator
  dim_img = SIZE(img)
  i1lru = MAKE_ARRAY(dim_img[1]*ratio, dim_img[2]*ratio, value=0.0, /DOUBLE)

  case dim_img[0] of
    2: begin
      i1lru = CONGRID(img, dim_img[1]*ratio, dim_img[2]*ratio, /CENTER)
    end
    3: begin
      i1lru = MAKE_ARRAY(dim_img[1]*ratio, dim_img[2]*ratio, dim_img[3], value=0.0, /DOUBLE)
      for i = 0, dim_img[3]-1 do begin
        i1lru[*, *, i] = CONGRID(img[*, *, i], dim_img[1]*ratio, dim_img[2]*ratio, /CENTER)
      endfor
    end
    else: begin
      PRINT, 'The image should have 2 or 3 dimensional data to perform Polynomial Interpolation.'
      i1lru = [0.*REPLICATE(0,dim_img[0])]
    end
  endcase

  RETURN, DOUBLE(i1lru)
end