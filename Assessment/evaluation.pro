;+
; FILENAME:
;    evaluation.pro
; PURPOSE:
;    ----------
;    A quality evaluation.
;    
; INPUT:
;    - I_GT           A ground truth image (3-Dimensions);
;    - I_REF          A fused imaged (3-Dimensions);
;    - RATIO          Scalling ratio - the value should be at the power of two.
;
; KEYWORD PARAMETERS:
;   QINDEX: If this keyword is set, a fusion between a high-pass filtered PAN and 
;       a MS is performed. Otherwise, only the high-pass filtered PAN is returned.
;
;   SAM_INDEX: If set, causes a linearization to be used before performing a filtering.
;       Otherwise, a standard high-pass filtering is performed.
;
;   SAM_MAP: If set, causes a linearization to be used before performing a filtering.
;       Otherwise, a standard high-pass filtering is performed.
;
;   ERGAS_INDEX: If set, causes a linearization to be used before performing a filtering.
;       Otherwise, a standard high-pass filtering is performed.
;       
; USAGE:
;       ENVI> A = EVALUATION, I_GT, I_REF, RATIO, QINDEX=qindex, SAM_INDEX=sam_index, $
;         SAM_MAP=sam_map, ERGAS_INDEX=ergas_index
;
; REVISION HISTORY:
;    2019-Sept-30  H.Cahyono
;                  Initial coding.
;-

pro EVALUATION, img_gt, img_ref, ratio, QINDEX = qindex, $
  SAM_INDEX = sam_index, SAM_MAP = sam_map, $
  ERGAS_INDEX = ergas_index
  if (ratio eq 0.0) then return
  if (N_ELEMENTS(qindex) OR ARG_PRESENT(qindex)) then qindex = QI(img_gt, img_ref)
  if (N_ELEMENTS(sam_index) OR ARG_PRESENT(sam_index))  then begin
    if (N_ELEMENTS(sam_map) OR ARG_PRESENT(sam_map)) then begin
      sam_index = SAM(img_gt, img_ref, MAP=sam_map)
    endif else sam_index = SAM(img_gt, img_ref)
  endif
  if (N_ELEMENTS(ergas_index) OR ARG_PRESENT(ergas_index)) then $
    ergas_index = ERGAS(img_gt, img_ref, ratio)
end