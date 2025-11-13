
view: view_to_be_refined {
  derived_table: {sql:select 1 as id;;}
  dimension: example_of_using_extended {sql:'initiated';;}
  dimension: exponential_growth {sql:2;;}
}

view: +view_to_be_refined {
  dimension: example_of_using_extended {sql:concat(${EXTENDED},' step 2');;}
  dimension: exponential_growth {sql:(${EXTENDED}).pow(2);;}
}

view: +view_to_be_refined {
  dimension: example_of_using_extended {sql:concat(${EXTENDED},' step 3');;}
  dimension: exponential_growth {sql:(${EXTENDED}).pow(2);;}
}



explore: view_to_be_refined {}


view: fnc {
  dimension: square_start {sql:pow(;;} dimension: square_end {sql:,2);;}

  # dimension: hypotenuse_before_x_param {sql:pow(pow(;;}  dimension: hypotenuse_after_x_param {sql:,2);;}
  # dimension: hypotenuse_before_y_param {sql:+ pow(;;} dimension: hypotenuse_after_y_param {sql:,2),(1/2));;}
}

view: v2 {
  derived_table: {sql:select 1 as id;;}
  dimension: id {}
  dimension: example_to_be_squared {type:number sql:3;;}
}
view: squared__function {dimension: squared__function_in_sql {sql:pow(REPLACE_ME,2);;}}

view: +v2 {
  extends: [squared__function]
  dimension: example_to_be_squared {sql:{{squared__function_in_sql._sql | split:'REPLACE_ME'|first}}${EXTENDED}{{squared__function_in_sql._sql | split:'REPLACE_ME'|last}};;}
}
view: +v2 {
  extends: [squared__function]
  dimension: example_to_be_squared {sql:{{squared__function_in_sql._sql | split:'REPLACE_ME'|first}}${EXTENDED}{{squared__function_in_sql._sql | split:'REPLACE_ME'|last}};;}
}
explore: v2 {}
view: +demo_data {dimension: example_to_be_squared {sql:{{- fnc.square_start._sql -}}${EXTENDED}{{- fnc.square_end._sql -}};;}}
view: +demo_data {dimension: example_to_be_squared {sql:{{- fnc.square_start._sql -}}${EXTENDED}{{- fnc.square_end._sql -}};;}}




view: +fnc {
  #hypotenuse function - parameterization type 1... safer and more flexible but more awkward?
  dimension: hypotenuse_before_x_param {sql:pow(pow(;;}
  dimension: hypotenuse_after_x_param {sql:,2);;}
  dimension: hypotenuse_before_y_param {sql:+ pow(;;}
  dimension: hypotenuse_after_y_param {sql:,2),(1/2));;}

  #hypotenuse function - parameterization type 2... prepare to replace
  dimension: hypotenuse_type_2 {sql:pow(pow(INPUT_X,2)+pow(INPUT_Y,2),(1/2));;}
}

view: demo_data {
  derived_table: {
    sql:
          select 1 as id,1 as length, 1 as height
union all select 2 as id,2 as length, 0 as height
union all select 3 as id,3 as length, 4 as height;;
  }
  dimension: id {}
  dimension: length {sql:${TABLE}.length;;}
  dimension: height {sql:${TABLE}.height;;}
  dimension: example_to_be_squared {type:number sql:4;;}
  dimension: calculated_hypotenuse {}
}
#create two new fields using the two versions of the function
view: +demo_data {
  dimension: calculated_hypotenuse {sql:{{- fnc.hypotenuse_before_x_param._sql -}}${length}{{- fnc.hypotenuse_after_x_param._sql -}}{{- fnc.hypotenuse_before_y_param._sql -}}${height}{{- fnc.hypotenuse_after_y_param._sql -}};;}
  dimension: calculated_hypotenuse_2 {sql:{{- fnc.hypotenuse_type_2._sql | replace: 'INPUT_X','${length}' | replace: 'INPUT_Y','${height}'}};;}
}
explore: demo_data {join: fnc {sql:;; relationship:one_to_one}}
