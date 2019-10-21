;+
; FILENAME:
;    resize_image.pro
; PURPOSE:
;    ----------
;    To resize a MS image by adjusting to PAN image
; INPUT:
;    - I_MS           A 3-dimensional image data;
;    - I_PAN          Image data of 2-dimensions;
;    - RATIO          Scalling ratio - the value should be at the power of two;
;    - MS_NYQ         The Nyquist frequencies for a multiband image (MS/GT);
;    - PAN_NYQ        The Nyquist frequency for a single band image (PAN); 
;    - NTERMS         The number of MTF filters;
;    - NCOEFF         The number of interpolation coefficients.
;
; KEYWORD PARAMETERS:
;   UPSAMPLING_PAN: If this keyword is set, a PAN image will be filtered using MTF first before 
;       performing a downsampling and then upsampling. Otherwise, the original PAN is used.
;
; OUTPUT:
;    - i_upsampling   An upsampling image is returned.
;    
; USAGE:
;       ENVI> A = RESIZE_IMAGE(I_MS, I_PAN, RATIO, MS_NYQ, PAN_NYQ, NTERMS, NCOEFF[, /UPSAMPLING_PAN])
;
; REVISION HISTORY:
;    2019-Sept-30  H.Cahyono
;                  Initial coding.
;-


function RESIZE_IMAGE, i_ms, i_pan, ratio, ms_nyq, $
  pan_nyq, nterms, ncoeff, UPSAMPLING_PAN = upsampling_pan

  if (2^ROUND(ALOG2(ratio)) ne ratio) then begin
    PRINT, 'Cancelled. The ratio should be the power of 2'
    RETURN, 0
  endif
  
  dim_ms = SIZE(i_ms) 
  dim_pan = SIZE(i_pan)
  
  if (dim_ms[0] ne 3 or dim_pan[0] ne 2) then begin
    PRINT, 'The MS image should have 3 dimensions, while the PAN should be in 2-dimensional data.'
    RETURN, 0
  endif

  resized_ms = MAKE_ARRAY(dim_ms[1]/ratio, dim_ms[2]/ratio, dim_ms[3], value=0.0, /DOUBLE)

  if (N_ELEMENTS(upsampling_pan) OR ARG_PRESENT(upsampling_pan)) then begin
    if ((dim_pan[1] eq dim_ms[1]) && (dim_pan[2] eq dim_ms[2])) then begin
      upsampling_pan = DOUBLE(i_pan)
    endif else begin
      i_pan_upsampled = MTF(i_pan, pan_nyq, nterms, ratio)
      upsampling_pan = REBIN(i_pan_upsampled, dim_pan[1]/ratio, dim_pan[2]/ratio)
    endelse
  endif

  for i=0, dim_ms[3]-1 do begin
    i_result = MTF(i_ms[*, *, i], ms_nyq[i], nterms, ratio)
    resized_ms[*, *, i] = REBIN(i_result, dim_ms[1]/ratio, dim_ms[2]/ratio)
  endfor

  i_upsampling = UPSAMPLING(resized_ms, ratio, 0)
  RETURN, i_upsampling
end