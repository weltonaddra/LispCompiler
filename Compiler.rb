expression = ''
firstVal = ''
output = ''

def evaluate(expression)
    if expression[0] == '('
        firstVal = expression[1]
        case expression
            when expression = '+'
                output = firstVal + secondVal
                puts output
            when expression = '-'
                output = firstVal - secondVal
                puts output
            when expression = '*'
                output = firstVal * secondVal
                puts output
            when expression = '/'
                output = firstVal / secondVal
                puts output
            when expression = '%'
                output = firstVal % secondVal
                puts output
        end
    else
        puts "Invalid operator no '(' found"
    end
end


