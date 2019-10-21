;+
; FILENAME:
;    size_adjustment.pro
; PURPOSE:
;    ----------
;    To adjust the size of a MS image.
;    
; INPUT:
;    - I_FUSED        A 3-dimensional image data (MS);
;    - RATIO          Scalling ratio - the value should be at the power of two;
;    - RESOLUTION     Radiometric resolution. Default: 11;
;    - DIM_BOUNDARY   The dimension boundary cutting. Default: 11.
;
; KEYWORD PARAMETERS:
;    - CUT_BOUNDARY: 
;    - THRESHOLDING: 
;
; OUTPUT:
;    - i_upsampling
;
; USAGE:
;       ENVI> A = SIZE_ADJUSTMENT(i_fused, RATIO, RESOLUTION, CUT_BOUNDARY=cut_boundary, 
;                   DIM_BOUNDARY, THRESHOLDING=thrshd)
;
; REVISION HISTORY:
;    2019-Sept-30  H.Cahyono
;                  Initial coding.
;-


function ADJUST_SIZE, img, dim_boundary
  dim_img = SIZE(img)
  img = img(dim_boundary:dim_img[1]-dim_boundary, $
    dim_boundary:dim_img[2]-dim_boundary, *)
  RETURN, img
end

function SIZE_ADJUSTMENT, i_fused, GT_IMAGE=i_gt, ratio, resolution, $
  dim_boundary, CUT_BOUNDARY=cut_boundary, THRESHOLDING=thrshd

  if (~ratio mod 2) then ratio = ratio + 1

  if (N_ELEMENTS(cut_boundary) OR ARG_PRESENT(cut_boundary)) then begin
    if (dim_boundary eq 0) then dim_boundary = 11 ; if dim_boundary is not set, put 11 as the default
    
    i_fused = ADJUST_SIZE(i_fused, dim_boundary)
    IF (N_ELEMENTS(i_gt) OR ARG_PRESENT(i_gt)) then begin
      dim_ifused = SIZE(i_fused, /DIMENSIONS)
      dim_igt = SIZE(i_gt, /DIMENSIONS)
      if (dim_igt[0] NE i_fused[0]) OR (dim_igt[1] NE i_fused[1]) then $
        i_gt = ADJUST_SIZE(i_gt, dim_boundary)
    endif
  endif

  ; adjust the image data
  if (N_ELEMENTS(thrshd) OR ARG_PRESENT(thrshd)) then begin
    i_fused[WHERE(i_fused gt 2^resolution)] = 2^resolution
    i_fused[WHERE(i_fused lt 0)] = 0
  endif

  RETURN, i_fused
end