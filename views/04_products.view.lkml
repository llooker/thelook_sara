view: products {
  sql_table_name: looker-private-demo.ecomm.products ;;

  ### DIMENSIONS ###

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: category {
    sql: TRIM(${TABLE}.category) ;;
    drill_fields: [item_name]
  }

  dimension: item_name {
    sql: TRIM(${TABLE}.name) ;;
  }

  dimension: brand {
    sql: TRIM(${TABLE}.brand) ;;
    link: {
      label: "Website"
      url: "http://www.google.com/search?q={{ value | encode_uri }}+clothes&btnI"
      icon_url: "http://www.google.com/s2/favicons?domain=www.{{ value | encode_uri }}.com"
    }
    link: {
      label: "Facebook"
      url: "http://www.google.com/search?q=site:facebook.com+{{ value | encode_uri }}+clothes&btnI"
      icon_url: "https://upload.wikimedia.org/wikipedia/commons/c/c2/F_icon.svg"
    }
    link: {
      label: "{{value}} Analytics Dashboard"
      url: "/dashboards-next/CRMxoGiGJUv4eGALMHiAb0?Brand%20Name={{ value | encode_uri }}"
      icon_url: "http://www.looker.com/favicon.ico"
    }

    action: {
      label: "Email Brand Promotion to Cohort"
      url: "https://desolate-refuge-53336.herokuapp.com/posts"
      icon_url: "https://sendgrid.com/favicon.ico"
      param: {
        name: "some_auth_code"
        value: "abc123456"
      }
      form_param: {
        name: "Subject"
        required: yes
        default: "Last Chance! 20% off {{ value }}"
      }
      form_param: {
        name: "Body"
        type: textarea
        required: yes
        default:
        "Dear Valued Customer,

        We appreciate your continue support and loyalty and wanted to show our appreciation. Offering a 15% discount on ALL products for our favorite brand {{ value }}.
        Just used code {{ value | upcase }}-MANIA on your next checkout!

        Your friends at the Look"
      }
    }
    action: {
      label: "Start Adwords Campaign"
      url: "https://desolate-refuge-53336.herokuapp.com/posts"
      icon_url: "https://www.google.com/s2/favicons?domain=www.adwords.google.com"
      param: {
        name: "some_auth_code"
        value: "abc123456"
      }
      form_param: {
        type: select
        name: "Campaign Type"
        option: { name: "Spend" label: "Spend" }
        option: { name: "Leads" label: "Leads" }
        option: { name: "Website Traffic" label: "Website Traffic" }
        required: yes
      }
      form_param: {
        name: "Campaign Name"
        type: string
        required: yes
        default: "{{ value }} Campaign"
      }

      form_param: {
        name: "Product Category"
        type: string
        required: yes
        default: "{{ value }}"
      }

      form_param: {
        name: "Budget"
        type: string
        required: yes
      }

      form_param: {
        name: "Keywords"
        type: string
        required: yes
        default: "{{ value }}"
      }
    }
  }

  dimension: retail_price {
    type: number
    sql: ${TABLE}.retail_price ;;
  }

  dimension: department {
    sql: TRIM(${TABLE}.department) ;;
  }

  dimension: sku {
    sql: ${TABLE}.sku ;;
  }

  dimension: distribution_center_id {
    type: number
    sql: CAST(${TABLE}.distribution_center_id AS INT64) ;;
  }

  ## MEASURES ##

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: brand_count {
    type: count_distinct
    sql: ${brand} ;;
    drill_fields: [brand, detail2*, -brand_count] # show the brand, a bunch of counts (see the set below), don't show the brand count, because it will always be 1
  }

  measure: category_count {
    alias: [category.count]
    type: count_distinct
    sql: ${category} ;;
    drill_fields: [category, detail2*, -category_count] # don't show because it will always be 1
  }

  measure: department_count {
    alias: [department.count]
    type: count_distinct
    sql: ${department} ;;
    drill_fields: [department, detail2*, -department_count] # don't show because it will always be 1
  }

  set: detail {
    fields: [id, item_name, brand, category, department, retail_price, customers.count, orders.count, order_items.count, inventory_items.count]
  }

  set: detail2 {
    fields: [category_count, brand_count, department_count, count, customers.count, orders.count, order_items.count, inventory_items.count, products.count]
  }
}
