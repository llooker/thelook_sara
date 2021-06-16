##### This model file contains information about which tables to use and how they should be joined together into an explores. An Explore is the starting place that end business users can query data and is the result of the LookML you are writing. #####


#This section defines the database connection, view files, and dashboard files used in this LookML project
connection: "looker-private-demo"
label: " eCommerce"
include: "/views/queries*.view" # includes all queries refinements
include: "/views/**/*.view" # include all the views
include: "/dashboards/*.dashboard.lookml" # include all the views

#This defines the caching policy for the Explores in the model file
datagroup: ecommerce_etl {
  sql_trigger: SELECT max(created_at) FROM ecomm.events ;;
  max_cache_age: "24 hours"
}

persist_with: ecommerce_etl


########  Explores: ########

# Explores allow you to join together different views (database tables) based on
# relationships between fields. By adding a view into an Explore, you make those
# fields available to users for data analysis.
# Explores should be purpose-built based on use cases.

# For example, to make the order_items view available to users,
# we define the following Explore:

explore: order_items {
  #This Explore is called “(1) Orders, Items and Users”
  label: "(1) Orders, Items and Users"
  view_name: order_items

# Let's talk about joining.  To create more sophisticated that involve multiple
# views, you can use the join parameter. Typically, join parameters require that
# you define the join type, a sql_on clause , and the view relationship.

# For example, the order_items Explore below joins together order_items, users, and
# many more views to provide users insight into sales and company performance.

# The join criteria is inserted by defining the type, sql_on, and relationship parameters.

  join: users {
    type: left_outer  # The type here is a left outer join.
    sql_on: ${order_items.user_id} = ${users.id} ;; # Specifies the common field between the views
    relationship: many_to_one  # A user can can have many ordered items, so the relationship
    # between order_items and users is many_to_one.
  }

  join: order_facts {
    type: left_outer
    view_label: "Orders"
    sql_on: ${order_facts.order_id} = ${order_items.order_id} ;;
    relationship: many_to_one
  }

  join: inventory_items {
    #Left Join only brings in items that have been sold as order_item
    type: full_outer
    relationship: one_to_one
    sql_on: ${inventory_items.id} = ${order_items.inventory_item_id} ;;
  }

  join: user_order_facts {
    view_label: "Users"
    type: left_outer
    relationship: many_to_one
    sql_on: ${user_order_facts.user_id} = ${order_items.user_id} ;;
  }

  join: products {
    type: left_outer
    relationship: many_to_one
    sql_on: ${products.id} = ${inventory_items.product_id} ;;
  }

  join: distribution_centers {
    type: left_outer
    sql_on: ${distribution_centers.id} = ${inventory_items.product_distribution_center_id} ;;
    relationship: many_to_one
  }

}


#########  Event Data Explores #########

explore: events {
  label: "(2) Web Event Data"



  join: product_viewed {
    from: products
    type: left_outer
    sql_on: ${events.viewed_product_id} = ${product_viewed.id} ;;
    relationship: many_to_one
  }

  join: users {
    type: left_outer
    sql_on: ${events.user_id} = ${users.id} ;;
    relationship: many_to_one
  }

  join: user_order_facts {
    type: left_outer
    sql_on: ${users.id} = ${user_order_facts.user_id} ;;
    relationship: one_to_one
    view_label: "Users"
  }
}
