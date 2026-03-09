#* 6: Compile tables for export
#+ 6.1: Combine all tables into single document with ternB
ternB(
  tables           = list(T1, T2, T3, T4),
  output_docx      = "Outputs/Tables/T1-T4.docx",
  methods_doc      = TRUE,
  methods_filename = "Outputs/Tables/T1-T4-methods.docx",
  font_family    = "Times New Roman"
)