include: "12_user_order_facts.view"
include: "01_order_items.view"

view: +user_order_facts {

  dimension: currently_active_customer {
    type: yesno
    sql: ${latest_order_date} >= DATE_ADD(CURRENT_DATE, INTERVAL -30 DAY) ;;
  }

  measure: active_user_count {
    type: sum
    filters: [lifetime_orders: "< 2", first_order_date: "before 30 days ago"]
    sql: ${user_id} ;;
  }

  measure: lost_user_count {
    type: number
    sql:  ;;
  }

  dimension: is_active_customer {}


}
