;+
; FILENAME:
;    hpf.pro
; PURPOSE:
;    ----------
;    To perform a pansharpening based on high-pass filtering algorithm. The 'average' filter is 
;    used as the based of the high-pass filtering. 
;    
; INPUT:
;    - I_MS           A 3-dimensional image data;
;    - I_PAN          Image data of 2-dimensions;
;    - RATIO          Scalling ratio - the value should be at the power of two;
;
; KEYWORD PARAMETERS:
;
;   FUSION: If this keyword is set, a fusion between a high-pass filtered PAN and 
;       a MS is performed. Otherwise, only the high-pass filtered PAN is returned;
;
;   EQUALIZATION: If set, causes a linearization to be used before performing a filtering.
;       Otherwise, a standard high-pass filtering is performed.
;
; OUTPUT:
;    - i_return       a 3-dimensional data of the sharpened image.
;
; USAGE:
;       ENVI> A = HPF(I_MS, I_PAN, RATIO[, /FUSION, /EQUALIZATION])
;
; REVISION HISTORY:
;    2019-Sept-30  H.Cahyono
;                  Initial coding.
;-

function HPF, ms_img, pan_img, ratio, FUSION=fus, EQUALIZATION=equal
  clock = TIC('HPF')
  dim_ms = SIZE(ms_img)
  i_pan = pan_img
  i_return = MAKE_ARRAY(dim_ms[1], dim_ms[2], dim_ms[3], value=0.0, /DOUBLE)

  for i=0, dim_ms[3]-1 do begin
    ; perform equalization if the the keyword is set
    if (N_ELEMENTS(equal) OR ARG_PRESENT(equal)) then $
      i_pan = EQUALIZE(ms_img[*, *, i], pan_img)

    smoothed_pan = SMOOTH(i_pan, ratio+1)       ; perform averaging on the PAN image
    i_return[*, *, i] = i_pan-smoothed_pan    ; perform single linear time-invariant

    ; since the HPF gain is 1, a fusion of PAN filtered image with 
    ; the multispectral band is performed
    if (N_ELEMENTS(fus) OR ARG_PRESENT(fus)) then $
      i_return[*, *, i] = ms_img[*, *, i] + i_return[*, *, i]
  endfor
  TOC, clock
  RETURN, i_return
end