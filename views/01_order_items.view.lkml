# The name of this view in Looker is "order_items".

view: order_items {
   # The sql_table_name parameter indicates the underlying database table to be used for all fields in this view.
  sql_table_name: looker-private-demo.ecomm.order_items ;;


  #PRO TIP: The order of the field definitions within a view doesn't matter.
  #         Organize fields in a way that makes sense for your organization.

  # Here's what a standard dimension looks like in LookML:
  dimension: sale_price {
    type: number
    value_format_name: usd
    sql: ${TABLE}.sale_price ;;
  }


  # Let's break this down and take a closer look at the LookML for a dimension:
  # This dimension will be called "id" within Looker
  dimension: id {

    # This id column is the unique key for this table in the underlying database. You need to identify the primary key in a view to join views in an Explore.
    primary_key: yes

    # This column is numeric (an integer) in the underlying database table.
    type: number

    # The underlying column in the products database table is called "id".
    # The ${TABLE} syntax references the table stated in the sql_table_name parameter.
    sql: ${TABLE}.id ;;
  }

  dimension: inventory_item_id {
    type: number
    # Hiding fields is useful if you don't want them to show up in the Explore UI.
    hidden: yes
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: user_id {
    type: number
    hidden: yes
    sql: ${TABLE}.user_id ;;
  }

 #PRO TIP: Use the Quick Help panel on the left to learn about the LookML syntax.

######## Measures: ########

 #   A measure is a summary or aggregate computation.
 #   Similar to the COUNT_DISTINCT function in SQL, you can use a measure of type: count distinct
 #   to count the distinct values in a field.

  measure: order_count {
    view_label: "Orders"
    #Click on type to see all the measures types you can use in the Quick Help panel
    type: count_distinct
    sql: ${order_id} ;;
  }


  measure: count_last_28d {
    label: "Count Sold in Trailing 28 Days"
    type: count_distinct
    sql: ${id} ;;
    hidden: yes
    filters:
    {field:created_date
      value: "28 days"
    }}

  measure: count {
    type: count
  }

  dimension: order_id_no_actions {
    type: number
    hidden: yes
    sql: ${TABLE}.order_id ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;

  }

  ########## Time Dimensions ##########

  dimension_group: returned {
    type: time
    timeframes: [time, date, week, month, raw]
    sql: ${TABLE}.returned_at ;;

  }

  dimension_group: shipped {
    type: time
    timeframes: [date, week, month, raw]
    sql: CAST(${TABLE}.shipped_at AS TIMESTAMP) ;;

  }

  dimension_group: delivered {
    type: time
    timeframes: [date, week, month, raw]
    sql: CAST(${TABLE}.delivered_at AS TIMESTAMP) ;;

  }

  dimension_group: created {
    type: time
    timeframes: [time, hour, date, week, month, year, hour_of_day, day_of_week, month_num, raw, week_of_year,month_name]
    sql: ${TABLE}.created_at ;;

  }

  dimension: reporting_period {
    group_label: "Order Date"
    sql: CASE
        WHEN EXTRACT(YEAR from ${created_raw}) = EXTRACT(YEAR from CURRENT_TIMESTAMP())
        AND ${created_raw} < CURRENT_TIMESTAMP()
        THEN 'This Year to Date'

        WHEN EXTRACT(YEAR from ${created_raw}) + 1 = EXTRACT(YEAR from CURRENT_TIMESTAMP())
        AND CAST(FORMAT_TIMESTAMP('%j', ${created_raw}) AS INT64) <= CAST(FORMAT_TIMESTAMP('%j', CURRENT_TIMESTAMP()) AS INT64)
        THEN 'Last Year to Date'

      END
       ;;
  }

  dimension: days_since_sold {
    hidden: yes
    sql: TIMESTAMP_DIFF(${created_raw},CURRENT_TIMESTAMP(), DAY) ;;
  }

  dimension: months_since_signup {
    view_label: "Orders"
    type: number
    sql: CAST(FLOOR(TIMESTAMP_DIFF(${created_raw}, ${users.created_raw}, DAY)/30) AS INT64) ;;
  }

########## Logistics ##########

  dimension: status {
    sql: ${TABLE}.status ;;
  }

  dimension: days_to_process {
    type: number
    sql: CASE
        WHEN ${status} = 'Processing' THEN TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), ${created_raw}, DAY)*1.0
        WHEN ${status} IN ('Shipped', 'Complete', 'Returned') THEN TIMESTAMP_DIFF(${shipped_raw}, ${created_raw}, DAY)*1.0
        WHEN ${status} = 'Cancelled' THEN NULL
      END
       ;;
  }


  dimension: shipping_time {
    type: number
    sql: TIMESTAMP_DIFF(${delivered_raw}, ${shipped_raw}, DAY)*1.0 ;;
  }


  measure: average_days_to_process {
    type: average
    value_format_name: decimal_2
    sql: ${days_to_process} ;;
  }

  measure: average_shipping_time {
    type: average
    value_format_name: decimal_2
    sql: ${shipping_time} ;;
  }

########## Financial Information ##########


  dimension: gross_margin {
    type: number
    value_format_name: usd
    sql: ${sale_price} - ${inventory_items.cost} ;;
  }

  dimension: item_gross_margin_percentage {
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${gross_margin}/nullif(0,${sale_price}) ;;
  }

  dimension: item_gross_margin_percentage_tier {
    type: tier
    sql: 100*${item_gross_margin_percentage} ;;
    tiers: [0, 10, 20, 30, 40, 50, 60, 70, 80, 90]
    style: interval
  }

  measure: total_sale_price {
    type: sum
    value_format_name: usd
    sql: ${sale_price} ;;
    drill_fields: [detail*]
  }

  measure: total_gross_margin {
    type: sum
    value_format_name: usd
    sql: ${gross_margin} ;;
    drill_fields: [detail*]
  }

  measure: average_sale_price {
    type: average
    value_format_name: usd
    sql: ${sale_price} ;;
    drill_fields: [detail*]
  }

  measure: median_sale_price {
    type: median
    value_format_name: usd
    sql: ${sale_price} ;;
    drill_fields: [detail*]
  }

  measure: average_gross_margin {
    type: average
    value_format_name: usd
    sql: ${gross_margin} ;;
    drill_fields: [detail*]
  }

  measure: total_gross_margin_percentage {
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${total_gross_margin}/ nullif(${total_sale_price},0) ;;
  }

  measure: average_spend_per_user {
    type: number
    value_format_name: usd
    sql: 1.0 * ${total_sale_price} / nullif(${users.count},0) ;;
    drill_fields: [detail*]
  }

########## Return Information ##########

  dimension: is_returned {
    type: yesno
    sql: ${returned_raw} IS NOT NULL ;;
  }

  measure: returned_count {
    type: count_distinct
    sql: ${id} ;;
    filters: {
      field: is_returned
      value: "yes"
    }
    drill_fields: [detail*]
  }

  measure: returned_total_sale_price {
    type: sum
    value_format_name: usd
    sql: ${sale_price} ;;
    filters: {
      field: is_returned
      value: "yes"
    }
  }

  measure: return_rate {
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${returned_count} / nullif(${count},0) ;;
  }



########## Sets ##########

  set: detail {
    fields: [id, order_id, status, created_date, sale_price, products.brand, products.item_name, users.portrait, users.name, users.email]
  }
  set: return_detail {
    fields: [id, order_id, status, created_date, returned_date, sale_price, products.brand, products.item_name, users.portrait, users.name, users.email]
  }
}
