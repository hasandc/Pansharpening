;+
; FILENAME:
;    mtf_glp.pro
; PURPOSE:
;    ----------
;    This function is used to get a fused image with a Modulation Transfer.
; INPUT:
;    - MS_IMG         A MS Image (3 Dimensions);
;    - PAN_IMG        A PAN Image (2 Dimensions);
;    - MS_NYQ         The Nyquist frequencies for a multiband image (MS/GT);
;    - PAN_NYQ        The Nyquist frequency for a single band image (PAN);
;    - NTERMS         The number of filters MTF;
;    - RATIO          Scalling ratio - the value should be at the power of two.
;
; KEYWORD PARAMETERS:
;   EQUALIZATION: If set, causes a linear equalization to be used before performing a filtering.
;       Otherwise, a MTF filtering is performed.
;
;   GLP: If this keyword is set, a Generalized Laplacian Pyramid (GLP) is performed
;       by exploiting general polynomial interpolator. Otherwise, only the MTF 
;       filtered PAN is returned.
;
;   FUSION: If set, a fusion of MS and filtered PAN is returned.
;       Otherwise, a standard MTF filtering image is performed.
;
; OUTPUT:
;    - i_return       A 3-Dimensional image (Multispectral).
;
; USAGE:
;       A = MTF_GLP(MS_IMG, PAN_IMG, MS_NYQ, PAN_NYQ, NTERMS, RATIO[, /EQUALIZATION, /GLP, /FUSION])
;
; REVISION HISTORY:
;    2019-Sept-30  H.Cahyono
;                  Initial coding.

function MTF_GLP, ms_img, pan_img, pan_Nyq, nterms, $
  ratio, GLP=glp, FUSION=fus, EQUALIZATION=equal
  clock = TIC('MTF_GLP')
  dim_ms = SIZE(ms_img)
  i_pan = pan_img

  i_return = MAKE_ARRAY(dim_ms[1], dim_ms[2], dim_ms[3], value=0.0, /DOUBLE)

  for i=0, dim_ms[3]-1 do begin
    if (N_ELEMENTS(equal) OR ARG_PRESENT(equal)) then $
      i_pan = EQUALIZE(ms_img[*, *, i], pan_img)
   
    i_return[*, *, i] = MTF(i_pan, pan_Nyq, nterms, ratio)

    if (N_ELEMENTS(glp) OR ARG_PRESENT(glp)) then begin
      t = REBIN(i_return[*, *, i], dim_ms[1]/ratio, dim_ms[2]/ratio)
      i_return[*, *, i] = POLINTERP_GENERAL(t, ratio)
    endif

    if (N_ELEMENTS(fus) OR ARG_PRESENT(fus)) then $
      i_return[*, *, i] = ms_img[*, *, i] + i_pan - i_return[*, *, i]
  endfor
  TOC, clock
  RETURN, DOUBLE(i_return)
end
