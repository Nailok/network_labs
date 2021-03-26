module Cypher
  def chunk(string, size)
    string.scan(/.{1,#{size}}/)
  end

  def self.generate_min_from_key(key)
    result = 0
    bytes = key.bytes.uniq
    max = 7
    min = 2
    bytes.map { |n| n % 10 }
    bytes.each { |n| result += n }

    while result <= min || result > 7
      result = result * 2 + 1 if result < min
      result = result / 2 - 1 if result > max / 2
    end
    result
  end

  def self.generate_max_from_key(key, min)
    bytes = key.bytes.uniq

    avg_bytes = 0
    bytes.each { |n| avg_bytes += n % 10 }
    result = avg_bytes

    while result <= min || result > 7
      result = result * 2 + 1 if result <= min
      result = result / 2 - 1 if result > 7
    end

    result
  end

  def self.encrypt(data, m = 4, n = 6)
    return data[1] + data[0] if data.length == 2

    m -= 1
    n -= 1

    n = data.length if n > data.length
    m = 1 if m >= n

    part1 = data[0...m]
    part2 = data[m..n - 1]
    part3 = data[n..data.length]

    part1 = ''  if part1.nil?
    part2 = ''  if part2.nil?
    part3 = ''  if part3.nil?
    # puts "part1 = #{part1}"
    # puts "part2 = #{part2}"
    # puts "part3 = #{part3}"
    # puts
    part3 + part2 + part1
  end

  def self.decrypt(data, m = 4, n = 6)
    return data[1] + data[0] if data.length == 2

    # m -= 1
    # n -= 1
    n = data.length if n > data.length
    m = 1 if m >= n

    part1 = data[0..data.length - n]
    part2 = data[data.length - n + 1..data.length - m]
    part3 = data[data.length - m + 1..data.length]

    part1 = ''  if part1.nil?
    part2 = ''  if part2.nil?
    part3 = ''  if part3.nil?
    # puts "data.length = #{data.length}"
    # puts "part1 = #{part1}"
    # puts "part2 = #{part2}"
    # puts "part3 = #{part3}"
    # puts
    part3 + part2 + part1
  end
end
