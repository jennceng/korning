# Use this file to import the sales information into the
# the database.
require "pg"
require "csv"
require "pry"

def db_connection
  begin
    connection = PG.connect(dbname: "korning")
    yield(connection)
  ensure
    connection.close
  end
end


@sales = []
@employees = []
@customers = []
@products = []
@frequencies = []

CSV.foreach('sales.csv', headers: true, header_converters: :symbol) do |row|
  hash = row.to_h
   @sales << hash
   @employees << hash[:employee]
   @customers << hash[:customer_and_account_no]
   @products << hash[:product_name]
   @frequencies << hash[:invoice_frequency]
end

@employees.uniq!
@customers.uniq!
@products.uniq!
@frequencies.uniq!

#these would be great methods

@names_emails = []
@employees.each do |employee|
  @names_emails << employee.split(' (')
end

@names_emails.each do |employee|
  employee.last.gsub!(/[\(\)]/, "")
end

@customers_numbers = []
@customers.each do |customer|
  @customers_numbers << customer.split(' (')
end

@customers_numbers.each do |customer|
  customer.last.gsub!(/[\(\)]/, "")
end

db_connection do |conn|
  @names_emails.each do |employee|
    # select everything with this employee's data
    # if we don't got results
    # binding.pry
    if conn.exec("SELECT * FROM employees WHERE employee_name = '#{employee[0]}'").to_a.size == 0
      # binding.pry
      query = "INSERT INTO employees (employee_name, employee_email) VALUES ($1, $2)"
      data = employee
      conn.exec_params(query, data)
    end
  end

  @customers_numbers.each do |customer|
    if conn.exec("SELECT * FROM customers WHERE customer_name = '#{customer[0]}'").to_a.size == 0
      query = "INSERT INTO customers (customer_name, customer_number) VALUES ($1, $2)"
      data = customer
      conn.exec_params(query, data)
    end
  end

  @products.each do |product|
    if conn.exec("SELECT * FROM products WHERE product_name = '#{product}'").to_a.size == 0
      query = "INSERT INTO products (product_name) VALUES ($1)"
      data = [product]
      conn.exec_params(query, data)
    end
  end

  @frequencies.each do |frequency|
    if conn.exec("SELECT * FROM invoice_frequencies WHERE invoice_frequency = '#{frequency}'").to_a.size == 0
      query = "INSERT INTO invoice_frequencies (invoice_frequency) VALUES ($1)"
      data = [frequency]
      conn.exec_params(query, data)
    end
  end

  @sales.each do |sale|

    @sale_date = sale[:sale_date]
    @sale_amount = sale[:sale_amount]
    @units_sold = sale[:units_sold]
    @invoice_number = sale[:invoice_no]
    # binding.pry
    if conn.exec("SELECT * FROM sales WHERE invoice_number = '#{@invoice_number}'").to_a.size == 0
      query = "SELECT products.id
      FROM products
      WHERE products.product_name = '#{sale[:product_name]}'"
      binding.pry
      @product_id = conn.exec(query).to_a.first["id"].to_i

      employee_name = sale[:employee].split(' (').first

      query = "SELECT employees.id
      FROM employees
      WHERE employees.employee_name = '#{employee_name}'"
      @employee_id = conn.exec(query).to_a.first["id"].to_i

      customer_name = sale[:customer_and_account_no].split(' (').first

      query = "SELECT customers.id
      FROM customers
      WHERE customers.customer_name = '#{customer_name}'"
      @customer_id = conn.exec(query).to_a.first["id"].to_i

      frequency_name = sale[:invoice_frequency]

      query = "SELECT invoice_frequencies.id
      FROM invoice_frequencies
      WHERE invoice_frequencies.invoice_frequency = '#{frequency_name}'"
      @frequency_id = conn.exec(query).to_a.first["id"].to_i

      query = %Q(INSERT INTO sales (sale_date, sale_amount, units_sold, invoice_number,
      product_id, customer_id, employee_id, invoice_frequency_id)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8))
      data = [@sale_date, @sale_amount, @units_sold, @invoice_number, @product_id, @customer_id, @employee_id, @frequency_id]
      conn.exec_params(query, data)
    end
  end
end
