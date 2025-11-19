; extends

; Custom highlighting for C
; Override void to use @keyword.void
(primitive_type) @keyword.void (#eq? @keyword.void "void")

; Capture "main" function name specifically
(function_declarator
  declarator: (identifier) @function.main (#eq? @function.main "main"))
