demographics_graded <- ternG(
  data = demographics_i,  group_var = "grade",
  group_order = c(3, 4, 5),
  output_xlsx = "demographics_graded.xlsx",
  output_docx = "demographics_graded.docx"
)