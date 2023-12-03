import gleam/io
import gleam/string
import gleam/iterator
import gleam/int
import gleam/list
import simplifile
import gleam/option.{type Option, None, Some}

pub type Cell {
  Number(n: Int)
  Symbol
  Empty
}

pub fn parse_int(s: String) -> Int {
  let assert Ok(n) = int.base_parse(s, 10)
  n
}

pub fn proc_line(line: String) -> List(Cell) {
  line
  |> string.split("")
  |> iterator.from_list
  |> iterator.map(fn(c: String) {
    let res = case c {
      "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ->
        Number(parse_int(c))
      "." -> Empty
      _ -> Symbol
    }
    res
  })
  |> iterator.to_list
}

pub fn access(maze: List(List(Cell)), x: Int, y: Int) -> Cell {
  case list.at(maze, x) {
    Error(_) -> Empty
    Ok(line) ->
      case list.at(line, y) {
        Error(_) -> Empty
        Ok(cell) -> cell
      }
  }
}

pub type ScanLineState {
  ScanLineState(nums: List(Int), curnum: Option(Int), curok: Bool)
}

pub fn adj_symbol(maze: List(List(Cell)), x: Int, y: Int) -> Bool {
  iterator.from_list([-1, 0, 1])
  |> iterator.map(fn(dx) {
    iterator.from_list([-1, 0, 1])
    |> iterator.map(fn(dy) {
      case #(dx, dy) {
        #(0, 0) -> False
        _ ->
          case access(maze, x + dx, y + dy) {
            Symbol -> True
            _ -> False
          }
      }
    })
    |> iterator.any(fn(x) { x })
  })
  |> iterator.any(fn(x) { x })
}

pub fn state_transition(
  state: ScanLineState,
  maze: List(List(Cell)),
  x: Int,
  y: Int,
) -> ScanLineState {
  let assert cell = access(maze, x, y)
  case cell {
    Number(n) -> {
      let new_num: Int = case state.curnum {
        None -> n
        Some(old) -> old * 10 + n
      }
      ScanLineState(
        nums: state.nums,
        curnum: Some(new_num),
        curok: state.curok || adj_symbol(maze, x, y),
      )
    }
    _ ->
      case state.curnum {
        None -> ScanLineState(nums: state.nums, curnum: None, curok: False)
        Some(n) ->
          ScanLineState(
            nums: case state.curok {
              True -> list.append(state.nums, [n])
              False -> state.nums
            },
            curnum: None,
            curok: False,
          )
      }
  }
}

pub fn finish(state: ScanLineState) -> Int {
  case #(state.curnum, state.curok) {
    #(Some(n), True) ->
      ScanLineState(nums: [n, ..state.nums], curnum: None, curok: False)
    _ -> state
  }.nums
  |> iterator.from_list
  |> iterator.fold(
    from: 0,
    with: fn(a, b) {
      // io.debug(b)
      a + b
    },
  )
}

pub fn main() {
  let file_path = "inputs/day3.in"
  let assert Ok(content) = simplifile.read(file_path)
  let maze: List(List(Cell)) =
    content
    |> string.split("\n")
    |> iterator.from_list
    |> iterator.map(fn(x) { proc_line(x) })
    |> iterator.to_list

  let hei = list.length(maze)

  let res: Int =
    iterator.range(0, hei - 1)
    |> iterator.map(fn(i) {
      let assert Ok(line) = list.at(maze, i)
      let wid = list.length(line)

      iterator.range(0, wid - 1)
      |> iterator.fold(
        from: ScanLineState(nums: [], curnum: None, curok: False),
        with: fn(state, j) { state_transition(state, maze, i, j) },
      )
      |> finish
    })
    |> iterator.fold(from: 0, with: fn(a, b) { a + b })

  res
  |> io.debug
}
