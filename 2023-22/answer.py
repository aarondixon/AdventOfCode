use std::collections::{HashSet, VecDeque};
use std::error::Error;
use std::fs::File;
use std::io::{BufRead, BufReader};
use std::time::Instant;

fn main() -> Result<(), Box<dyn Error>> {
    println!("\nDay 24 Advent of Code\n"); 

    let start = Instant::now();

    for input in ["./data/sample1.txt", 
                  "./data/input1.txt"
                  ] {
        let bricks = part_1(input)?;
        part_2(bricks)?;
    }

    let duration = start.elapsed();

    println!("\nTime elapsed to complete part 1 & 2 is: {:?}\n", duration);
    
    Ok(())
}

/// Part 1: Figure how the blocks will settle based on the snapshot. Once 
///         they've settled, consider disintegrating a single brick; how many 
///         bricks could be safely chosen as the one to get disintegrated?
/// 
fn part_1(path: &str) -> Result<Vec<Brick>, Box<dyn Error>> {
    let reader = BufReader::new(File::open(path)?);
    let lines  = reader.lines();

    let mut bricks = Vec::new();
    let mut hgrid  = [[NO_BRICK; 10]; 10];
    let mut count  = 0;
    
    for line in lines {
        let points = line?.split(&[',','~']).map(|s| s.parse())
                          .collect::<Result<Vec<usize>, _>>()?;
        bricks.push(Brick::new(&points));
    }
    bricks.sort_by_key(|b| b.lo_z());
    bricks.iter_mut().enumerate().for_each(|(i, b)| b.set_id(i));

    for b in 0..bricks.len() {
        let mut brick = bricks[b].clone();
        brick.land(&mut hgrid, &mut bricks);
        bricks[b] = brick;
    }
    for b in 0..bricks.len() {
        if bricks[b].can_safely_remove(&bricks) {
            count += 1;
        }
    }

    println!("Part 1 Total safely removed...: {}", count);
    Ok(bricks)
}

/// Part 2: For each brick, determine how many other bricks would fall if that 
///         brick were disintegrated. What is the sum of the number of other 
///         bricks that would fall?
/// 
fn part_2(bricks: Vec<Brick>) -> Result<usize, Box<dyn Error>> {
    let mut count = 0;
    let mut is_falling = vec![false; bricks.len()];
    let mut queue      = VecDeque::new();

    for b in &bricks {
        is_falling[b.id()] = true;
        queue.push_back(b.id());
        
        while let Some(b) = queue.pop_front() {
            for &b in bricks[b].above() {
                if !is_falling[b] && bricks[b].will_fall(&is_falling) {
                    is_falling[b] = true;
                    queue.push_back(b);
                    count += 1;
                }
            }
        }
        is_falling.fill(false);
    }
    println!("Part 2 Total will fall........: {}", count);
    Ok(count)
}

/// A simple identifier type for bricks which can also be used as array indices.
/// 
type BrickID = usize;
const NO_BRICK: BrickID = usize::MAX;

/// A brick is a rectangular block with a unique identifier and a list of 
/// bricks above and below it. These serve as adjacency lists if thinking of
/// the bricks and their points of contact as vertices and edges.
/// 
#[derive(Debug, Clone)]
struct Brick {
    x1 : usize,
    y1 : usize,
    z1 : usize,
    x2 : usize,
    y2 : usize,
    z2 : usize,    
    id : usize,
    below: Vec<BrickID>,
    above: Vec<BrickID>,
}
impl Brick {
    fn new(coords: &[usize]) -> Self {
        Self {
            x1 : coords[0],
            y1 : coords[1],
            z1 : coords[2],
            x2 : coords[3],
            y2 : coords[4],
            z2 : coords[5],
            id : 0,
            below: Vec::with_capacity(10),
            above: Vec::with_capacity(10),
        }
    }
    fn id(&self) -> usize {
        self.id
    }
    fn set_id(&mut self, id: usize) {
        self.id = id;
    }
    /// Returns the ID's of the bricks resting on top of this brick.
    /// 
    fn above(&self) -> &[BrickID] {
        &self.above
    }

    /// Returns true if the brick can be removed without upseting other bricks.
    /// 
    fn can_safely_remove(&self, bricks: &[Brick]) -> bool {
        for &b in &self.above {
            if bricks[b].below.len() == 1 {
                return false;
            }
        }
        true
    }

    /// Returns true if the brick(s) this one is resting on are falling and
    /// there are no other supports that aren't falling.
    /// 
    fn will_fall(&self, is_falling: &[bool]) -> bool {
        self.below.iter().all(|&b| is_falling[b])
    }

    /// Lands the brick on the platform and updates the platform and bricks.
    /// 
    fn land(&mut self, 
            platform : &mut [[BrickID; 10]; 10],
            bricks   : &mut [Brick]) 
    {
        let mut below = HashSet::new();
        let mut high  = 0;

        for x in self.x1..=self.x2 {
            for y in self.y1..=self.y2 {
                if platform[x][y] != NO_BRICK {
                    high = high.max(bricks[platform[x][y]].hi_z());
                    below.insert(platform[x][y]);
                }
                platform[x][y] = self.id;
            }
        }
        for id in below {
            if bricks[id].hi_z() == high {
                self.below.push(id);
                bricks[id].above.push(self.id);
            }
        }
        if self.z1 < self.z2 {
            let d   = self.z2 - self.z1;
            self.z1 = high + 1;
            self.z2 = self.z1 + d;
        } else {
            let d   = self.z1 - self.z2;
            self.z2 = high + 1;
            self.z1 = self.z2 + d; 
        }
    }

    /// Returns the highest Z point of the brick.
    /// 
    fn hi_z(&self) -> usize {
        self.z1.max(self.z2)
    }

    /// Returns the lowest Z point of the brick.
    /// 
    fn lo_z(&self) -> usize {
        self.z1.min(self.z2)
    }
}
