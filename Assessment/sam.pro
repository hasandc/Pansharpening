;+
; FILENAME:
;    sam.pro
; PURPOSE:
;    ----------
;    To calculate the Spectral Angle Mapper (SAM) based on two different multispectal images.
;
; INPUT:
;    - I_GTS          A ground truth image (multispectal);
;    - I_FUSED        A fused image (multispectral).
;
; KEYWORD PARAMETERS:
;   sam_map: If this keyword is set, a SAM map and SAM Index will be returned. Otherwise, only 
;   SAM Index is returned.
;
; OUTPUT:
;    - sam_index      SAM Index value (degree).
;
; USAGE:
;       ENVI> A = SAM(I_GT, I_FUSED, MAP=sam_map)
;
; REVISION HISTORY:
;    2019-Sept-30  H.Cahyono
;                  Initial coding.
;-

function SAM, i_gt, i_fused, MAP=sam_map
  eps = 1e-16         ;2^(-16)    ; eps value is hard coded to prevent 'devided by zero' values.
  dim_fused = SIZE(i_fused, /DIMENSIONS)
  prod_scal = DOT_PRODUCT(i_gt, i_fused)
  norm_orig = DOT_PRODUCT(i_gt, i_gt)
  norm_fuse = DOT_PRODUCT(i_fused, i_fused)
  prod_norm = SQRT(norm_orig*norm_fuse)
  prod_map = prod_norm

  dim_pmap = SIZE(prod_map)
  prod_map = REFORM(prod_map, dim_pmap[1]*dim_pmap[2])
  
  ; update every index which has value of zero into 'eps'
  prod_map[WHERE(prod_map eq 0)] = eps
  prod_map = REFORM(prod_map, dim_pmap[1], dim_pmap[2])

  if (N_ELEMENTS(sam_map) OR ARG_PRESENT(sam_map)) then $
    sam_map = ACOS(prod_scal/prod_map)

  prod_scal = REFORM(prod_scal, dim_fused[0]*dim_fused[1])
  prod_norm = REFORM(prod_norm, dim_fused[0]*dim_fused[1])

  ; to prevent NaN value, exclude every data which has zero value
  idx = WHERE(prod_norm ne 0)
  if (idx[0] eq -1) then RETURN, 0

  dim_pnorm = SIZE(prod_norm[idx])
  tot = prod_scal[idx]/prod_norm[idx]

  angel = TOTAL(TOTAL(ACOS(tot)))/dim_pnorm[1]
  
  ; convert radian value into Degree
  sam_index = DOUBLE(angel)*180./!DPI
  RETURN, sam_index
end

