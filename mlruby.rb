#module FunctionalExtensions
  module Match
    def self.with(value, statements)
        avalue=[*value]
        statements.keys.each_with_index{|key, i|
          akey=(Range===key) ? [key] : [*key]
          if ((akey.zip avalue).select { |ki, vi| ki==:_ ||
                                                  ki===vi ||
                                                  (Proc===ki && ki.call(vi))
                                       }
              ).length==avalue.length
            result=statements.values[i]
            result=(Proc===result) ? result.call(value) : result
            result=(:self==result) ? value : result
            return result
          end
        }
    end
  end
#end

#include FunctionalExtensions

#match array Booleans, with a an anonymous function test, don't care

puts Match.with([true,5],
  {[true, ->(x) {x.odd?}] => "true-odd",
   [true, ->(x) {x.even?}] => "true-even",
   [false, :_ ]  => "Don't care"}
)

#match array Booleans don't care
puts Match.with([false,true],
  {[true,  true] => "true-true",
   [true, false] => "true-false",
   [false, :_ ]  => "Don't care"}
)

#match single Boolean don't care
puts Match.with(false,
  {false => "False",
   :_    => "Don't Care"}
)

#match single integer with anonymous function
puts Match.with(5,
     {->x {x.even?} => "even",
      ->x {x.odd?} => "odd"})

#match type
puts Match.with(6,
     {Fixnum => "fixnum",
      String => "string"})

#match range
puts Match.with(6,
     {(0..3) => "small",
      (4..6) => "six",
      (4...6) => "medium"})

#range
puts Match.with(15,
     {(0..10) => :self,
      (11..20) => "invalid"})

#regular expression
puts Match.with("Cats are smarter than dogs",
     {/Cats(.*)/ => "Cats",
      :_ => "No Cats"})


#use for function definition
def fibonacci(i)
  Match.with(i,
    {0  => 0,
     1  => 1,
     :_ => -> i { fibonacci(i-1) + fibonacci(i-2)}})
end

#use for function definition
def factorial(i)
  Match.with(i,
    {0  => 1,
     :_ => -> i { i*factorial(i-1)}})
end

puts fibonacci 1
puts fibonacci 7
puts factorial 5



class Object
  def pipe(callable)
    callable.(self)
  end
end

#alternative syntax for range
class Numeric
  def to(top)
    (self...top)
  end
end

#alternative syntax for range
class Range
  def inclusive
    (self.begin..self.end)
  end
end

puts (2.to 9).exclude_end?
puts ((2.to 9).inclusive).exclude_end?


puts Match.with(15,
     {(0.to 10) => :self,
      (11.to 20).inclusive => "invalid"})

#alternative implementation of pipe
# class Proc
#   def self.pipe(f,g)
#     lambda {g[f.()]}
#   end
#   def >=(g)
#     Proc.pipe(self,g)
#   end
# end

class Pipeline
  def self.|(statements)
    statements.inject{ |result, statement|  result.pipe(statement) }
  end
end

#require 'celluloid'
class AsynchronousPipeline
  def self.|(statements)
    statements.inject{ |result, statement|  result.pipe(statement) }
  end
end

add3 = -> x {x + 3}
square = -> x {x*x}

puts 3.pipe(add3).pipe(square)

#3.|(add3).|(square)
#3.|add3.|square

puts Pipeline |[3,
                add3,
                square,
                square ]

#puts | |[3, add3, square, square]


puts AsynchronousPipeline |[4,
                             square,
                             add3]

