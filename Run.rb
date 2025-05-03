def standard_env
  {
    '(' => ->(x) { evaluate },
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
    'lambda' => ->(params, body, env) { ->(*args) { evaluate(body, env.merge(Hash[params.zip(args)])) } },
    'eval' => ->(expression, env) { evaluate(expression, env) } # Add eval function
  }
end

def is_number?(str)
  # Helper function to check if a string is a number
  if str != '>' || str != '<' || str != '='
    return false  
  end  
  
  Integer(str)
  
  true
rescue ArgumentError
  Float(str)
  true
rescue ArgumentError
  false
end

def remove_outer_parentheses(expression)
  expression.gsub(/[()]/, '')
end

def starts_with_parentheses(expression)
  if expression.is_a?(String)
    # Check if the string starts and ends with parentheses
    return expression.start_with?('(') && expression.end_with?(')')
  elsif expression.is_a?(Array)
    # Check if the first and last elements of the array are parentheses
    return expression.first == '(' && expression.last == ')'
  end
  false
end

def evaluate(expression, env = standard_env)
  if starts_with_parentheses(expression)
    # Remove the outer parentheses and tokenize the expression
    tokens = expression[1..-2].split
    operator = tokens[0]
    args = tokens[1..]

    # Process arguments
    i = 0
    while i < args.length
      arg = args[i]

      if starts_with_parentheses(arg)
        # Find the full nested expression
        nested_expression = arg
        open_parens = 1
        j = i + 1

        while j < args.length && open_parens > 0
          nested_expression += " #{args[j]}"
          open_parens += 1 if args[j].start_with?('(')
          open_parens -= 1 if args[j].end_with?(')')
          j += 1
        end

        # Recursively evaluate the nested expression
        evaluated_nested = evaluate(nested_expression, env)

        # Replace the nested expression with its evaluated result
        args[i] = evaluated_nested

        # Remove the processed tokens from the argument list
        args.slice!(i + 1, j - i - 1)
      else
        # Evaluate atomic arguments (numbers or variables)
        if is_number?(arg)
          args[i] = arg.include?('.') ? arg.to_f : arg.to_i
        elsif env.key?(arg)
          args[i] = env[arg] # Replace variables with their values
        end
        i += 1
      end
    end

    # Handle special forms and operators
    if operator == 'if'
      # Handle 'if' special form
      cond = args[0] # The condition is already evaluated
      if cond
        return evaluate(args[1], env) # Evaluate the true branch
      else
        return evaluate(args[2], env) # Evaluate the false branch
      end

    elsif operator == 'def'
      # Handle 'def' special form
      name = args[0]
      value = args[1]
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

  # If the expression is not a complex expression, check if it's a number or variable
  if is_number?(expression)
    return expression.include?('.') ? expression.to_f : expression.to_i
  elsif env.key?(expression)
    return env[expression] # Return the value of the variable
  end

  # If the expression is not recognized, raise an error
  raise "Invalid expression: #{expression}"
end

# Initialize the global environment
global_env = standard_env

# Test operations with the persistent environment
puts evaluate('(+ 5 3)', global_env)  # => 8
puts evaluate('(- 10 4)', global_env) # => 6
puts evaluate('(* 2 6)', global_env)  # => 12
puts evaluate('(/ 8 2)', global_env)  # => 4
puts evaluate('(max 1 5 3)', global_env) # => 5
puts evaluate('(list 1 2 3)', global_env) # => [1, 2, 3]
puts evaluate('(def x 10)', global_env) # Expected output: "x defined as 10"
puts evaluate('(def y 20)', global_env) # Expected output: "y defined as 20"
puts evaluate('(if (> x y) x y)', global_env) # Expected output: 20
puts evaluate('(print "Hello," "world!")', global_env) # Expected output: "Hello, world!"
puts evaluate('(null? (list))', global_env) # Expected output: true
puts evaluate('(null? (list 1 2))', global_env) # Expected output: false
puts evaluate('(length (list 1 2 3))', global_env) # Expected output: 3

