;; extends

;; Custom highlighting for Java
;; This file extends the default Java highlights

;; Override void_type to use a custom group instead of @type.builtin
(void_type) @keyword.void

;; Capture "main" function name specifically
(method_declaration
  name: (identifier) @function.main (#eq? @function.main "main"))
