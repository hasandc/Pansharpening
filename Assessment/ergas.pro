;+
; FILENAME:
;    ergas.pro
; PURPOSE:
;    ----------
;    Erreur Relative Globale Adimensionnelle de Synthï¿½se (ERGAS).
;    
; INPUT:
;    - IMG1           First 3-dimensional image data;
;    - IMG2           Second 3-dimensional image data;
;    - RATIO          Scalling ratio - integer -  the value should be at the power of two.
;
; OUTPUT:
;    - ergas_value    The value of ERGAS Index
;
; USAGE:
;       ENVI> A = ERGAS(IMG1, IMG2, RATIO)
;
; REVISION HISTORY:
;    2019-Sept-30  H.Cahyono
;                  Initial coding.
;-

function ERGAS, img1, img2, ratio
  err = DOUBLE(img1) - DOUBLE(img2)
  dim_err = SIZE(err)
  ergas_index = 0.0

  for i=0, dim_err[3]-1 do begin
    ergas_index = ergas_index + MEAN(err[*, *, i]^2)/MEAN(img1[*, *, i])^2
  endfor
  ergas_value = (100./ratio) * SQRT((1./dim_err[3]) * ergas_index)

  RETURN, ergas_value
end