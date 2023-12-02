use std::fs;

const DIGITS: [&str; 10] = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"];

fn is_digit(c: char) -> bool {
    c >= '0' && c <= '9'
}

fn get_digit(s: &str) -> Option<(i32, i32)>{
    let c = s.chars().next()?;
    if is_digit(c){
        return Some((c as i32 - '0' as i32, 1));
    }
    for digit in DIGITS.iter() {
        if s.starts_with(digit) {
            return Some((DIGITS.iter().position(|&r| r.eq(*digit)).unwrap() as i32 + 1, 1));
        }
    }
    None
}

fn main() {
    let contents = fs::read_to_string("inputs/day1.in");
    let mut tot = 0;
    for l in contents.unwrap().split("\n") {
        let mut first_i = -1;
        let mut last_i = -1;
        let mut i = 0;
        while i < l.len() {
            if let Some((digit, len)) = get_digit(&l[i..]){
                if first_i == -1 {
                    first_i = digit;
                }
                last_i = digit;
                i += len as usize;
            } else {
                i+=1;
            }
        }
        let delt = first_i*10 + last_i;
        tot += delt;
    }
    println!("{}", tot);
}
