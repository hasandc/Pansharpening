;+
; FILENAME:
;    equalize.pro
; PURPOSE:
;    ----------
;    A linear equalization of MS and PAN images.
; INPUT:
;    - MS_IMG           A 2-dimensional MS image data;
;    - PAN_IMG          A 2-dimensional PAN image data.
;
; OUTPUT:
;    - new_pan          A new equalized 2-Dimensional PAN Image.
;
; USAGE:
;       ENVI> A = EQUALIZE(MS_IMG, PAN_IMG)
;
; REVISION HISTORY:
;    2019-Sept-30  H.Cahyono
;                  Initial coding.
;-

function EQUALIZE, ms_img, pan_img
  ;new_pan = (pan_img - MEAN(pan_img))+ MEAN(ms_img)
  new_pan = (pan_img - MEAN(pan_img))*(STDDEV(ms_img)/STDDEV(pan_img)) + MEAN(ms_img)
  RETURN, new_pan
end