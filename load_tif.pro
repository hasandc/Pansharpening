;+
; FILENAME:
;    load_tif.pro
; PURPOSE:
;    ----------
;    To select an image file. Despite the use of deprecated ENVI_SELECT, ENVI_FILE_QUERY,
;    and ENVI_GET_DATA functions, this code has been tested to work properly on 
;    ENVI 5.5/ IDL 8.7.2.
;    
; INPUT:
;    - WIN_TITLE            A title of file selection dialog (String).
;
; OUTPUT:
;    - image                An imaging data from a selected file (2-D or 3-D).
;
; USAGE:
;       ENVI> A = LOAD_TIF(WIN_TITLE)
;
; REVISION HISTORY:
;    2019-Sept-30  H.Cahyono
;                  Initial coding.
;-

function LOAD_TIF, win_title
  COMPILE_OPT IDL2
  e = ENVI()

  ; This command will make an image selection and return 0 if no image is being selected.
  ENVI_SELECT, title=win_title, fid=fid, dims=dims, pos=pos

  ; if no image is selected, set the return value into 0
  if (fid eq -1) then begin
    PRINT, 'Cancelled'
    RETURN, 0
  endif

  ENVI_FILE_QUERY, fid, fname=fname

  ; image dimensions: columns, rows, and bands.
  cols = dims[2]- dims[1]+1
  rows = dims[4]- dims[3]+1
  bands = N_ELEMENTS(pos)

  ; space initiation for image data
  image = FLTARR(cols, rows)

  ; if bands is greather than 1, the selected image is a multiband image (MS or GT).
  ; Otherwise, single band image is assumed (PAN).
  if (bands gt 1) then begin
    ; 3-dimensional data.
    image = FLTARR(cols, rows, bands)
    for i=0, bands-1 do begin
      image[*, *, i] = ENVI_GET_DATA(fid=fid, dims=dims, pos=pos[i])
    endfor
  endif else begin
    image[*, *] = ENVI_GET_DATA(fid=fid, dims=dims, pos=pos)
  endelse

  RETURN, image
end