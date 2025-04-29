def standard_env
  {
    #Used for all the different possible operations and deals with handling them 
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
    'print' => ->(x) { puts x },
    'list' => ->(*args) { args },
    'car' => ->(list) { list[0] },
    'cdr' => ->(list) { list[1..-1] },
    'cons' => ->(x, y) { [x] + y },
    'null?' => ->(x) { x.empty? },
    'length' => ->(list) { list.length },
    'if' => ->(cond, true_branch, false_branch) { cond ? true_branch : false_branch },
    'def' => ->(name, value, env) { env[name] = value },
    'lambda' => ->(params, body, env) { ->(*args) { evaluate(body, env.merge(Hash[params.zip(args)])) } }
  }
end


def evaluate(expression, env = standard_env)
  tokens = expression.gsub(/[()]/, '').split # Tokenize the input
  operator = tokens[0]
  args = tokens[1..]

  # Check if the expression is a number
  if expression.match?(/^\d+$/) # Match integers
    return expression.to_i
  elsif expression.match?(/^\d+\.\d+$/) # Match floats
    return expression.to_f
  end

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
    
  elsif operator == 'lambda'
    # Handle 'lambda' special form
    params = args[0..-2]
    body = args[-1]
    return ->(*lambda_args) { evaluate(body, env.merge(Hash[params.zip(lambda_args)])) }
  elsif env.key?(operator)
    # Handle regular functions
    evaluated_args = args.map { |arg| evaluate(arg, env) } # Evaluate each argument
    result = env[operator].call(*evaluated_args) # Call the operator with evaluated arguments
    puts result
  else
    # Handle unknown operators or variables
    if env.key?(operator)
      return env[operator] # Return the variable's value
    else
      raise "Unknown operator or variable: #{operator}"
    end
  end
end

global_env = standard_env

# Test operations with the persistent environment
evaluate('(+ 5 3)', global_env)  # => 8
evaluate('(- 10 4)', global_env) # => 6
evaluate('(* 2 6)', global_env)  # => 12
evaluate('(/ 8 2)', global_env)  # => 4
evaluate('(max 1 5 3)', global_env) # => 5
evaluate('(list 1 2 3)', global_env) # => [1, 2, 3]
evaluate('(def x 10)', global_env) # Expected output: "x defined as 10"
evaluate('(def y 20)', global_env) # Expected output: "y defined as 20"
evaluate('(if (> x y) x y)', global_env) # Expected output: 20
evaluate('(print "Hello, World!")', global_env) # Expected output: "Hello, World!"
evaluate('(null? (list))', global_env) # Expected output: true
evaluate('(null? (list 1 2))', global_env) # Expected output: false
evaluate('(length (list 1 2 3))', global_env) # Expected output: 3

#list structure

