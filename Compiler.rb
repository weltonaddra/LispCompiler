def standard_env
  {
    '+' => ->(x, y) { x + y },
    '-' => ->(x, y) { x - y },
    '*' => ->(x, y) { x * y },
    '/' => ->(x, y) { x / y },
    '%' => ->(x, y) { x % y },
    '>' => ->(x, y) { x > y },
    '<' => ->(x, y) { x < y },
    '>=' => ->(x, y) { x >= y },
    '<=' => ->(x, y) { x <= y },
    '=' => ->(x, y) { x == y },
    'abs' => ->(x) { x.abs },
    'max' => ->(*args) { args.max },
    'min' => ->(*args) { args.min },
    'print' => ->(*args) { puts args.join(' ') }, # Allow multiple arguments
    'list' => ->(*args) { args },
    'car' => ->(list) { list[0] },
    'cdr' => ->(list) { list[1..-1] },
    'cons' => ->(x, y) { [x] + y },
    'null?' => ->(list) { list.empty? },
    'length' => ->(list) { list.length },
    'if' => ->(cond, true_branch, false_branch) { cond ? true_branch : false_branch },
    'def' => ->(name, value, env) { env[name] = value },
    'lambda' => ->(params, body, env) { ->(*args) { evaluate(body, env.merge(Hash[params.zip(args)])) } }
  }
end

def is_number?(str)
  # Helper function to check if a string is a number
  Integer(str)
  true
rescue ArgumentError
  Float(str)
  true
rescue ArgumentError
  false
end

def evaluate(expression, env = standard_env)

  # Check if the expression is a complex expression
  if expression.start_with?('(') && expression.end_with?(')')
    # Remove the outer parentheses and tokenize the expression
    tokens = expression[1..-2].split
    operator = tokens[0]
    args = tokens[1..]

    # Check for numbers in the arguments
    args.each_with_index do |arg, index|
      if is_number?(arg)
        args[index] = arg.include?('.') ? arg.to_f : arg.to_i
      elsif env.key?(arg)
        args[index] = env[arg] # Replace variables with their values
      end
    end

    # Handle special forms and operators
    if operator == 'if'
      # Handle 'if' special form
      cond = evaluate(args[0], env) # Evaluate the condition
      if cond
        return evaluate(args[1], env) # Evaluate the true branch
      else
        return evaluate(args[2], env) # Evaluate the false branch
      end

    elsif operator == 'def'
      # Handle 'def' special form
      name = args[0]
      value = evaluate(args[1], env)
      env[name] = value
      puts "#{name} defined as #{value}"
      return value

    elsif operator == 'lambda'
      # Handle 'lambda' special form
      params = args[0..-2]
      body = args[-1]
      return ->(*lambda_args) { evaluate(body, env.merge(Hash[params.zip(lambda_args)])) }

    elsif env.key?(operator)
      # Handle regular functions
      result = env[operator].call(*args) # Call the operator with evaluated arguments
      return result

    else
      # Handle unknown operators
      raise "Unknown operator: #{operator}"
    end
  end

  # If the expression is not recognized, raise an error
  raise "Invalid expression: #{expression}"
end

# Initialize the global environment
global_env = standard_env

# # Test operations with the persistent environment
# puts evaluate('(+ 5 3)', global_env)  # => 8
# puts evaluate('(- 10 4)', global_env) # => 6
# puts evaluate('(* 2 6)', global_env)  # => 12
# puts evaluate('(/ 8 2)', global_env)  # => 4
# puts evaluate('(max 1 5 3)', global_env) # => 5
# puts evaluate('(list 1 2 3)', global_env) # => [1, 2, 3]
# puts evaluate('(def x 10)', global_env) # Expected output: "x defined as 10"
# puts evaluate('(def y 20)', global_env) # Expected output: "y defined as 20"
puts evaluate('(if (> x y) x y)', global_env) # Expected output: 20
puts evaluate('(print "Hello," "world!")', global_env) # Expected output: "Hello, world!"
puts evaluate('(null? (list))', global_env) # Expected output: true
puts evaluate('(null? (list 1 2))', global_env) # Expected output: false
puts evaluate('(length (list 1 2 3))', global_env) # Expected output: 3

