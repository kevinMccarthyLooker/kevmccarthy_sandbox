connection: "default_bigquery_connection"

include: "/stable_table_name_pdt.view.lkml"
view: +stable_table_name_pdt {
  extends: [stable_table_name_pdt]
  #reset sql to point to the stable_table_name
  derived_table: {
    sql:select * from thekitchentable.thekitchentablePDTs.8K_kevmccarthy_sandbox_stable_table_name_pdt;;
  }
  dimension: id {}
}
explore: stable_table_name_pdt {
  hidden: yes
}
