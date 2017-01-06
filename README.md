# Blocky Roads
>a game designed for *Nexys4* FPGA

---

![](https://github.com/Fairyland0902/BlockyRoads/raw/master/pics/Blocky_Roads.png)

---

# Overall Structure
- MVC Frame
![](https://github.com/Fairyland0902/BlockyRoads/raw/master/pics/MVC.png)

---

# Overall Structure
- *Verilog* Code of the TOP Module
```verilog
module BR_Top(input and output signals);

    // Signal declaration
    . . .

    Renderer render_unit (parameters);
    Controller control_unit (parameters);
    Model model_unit (parameters);

endmudule

```

---

# Model

---

# Components
- Seg_disp
  > a module to display the highest score on the segment tube

---

## Seg_disp
- User-defined Characters
```verilog
case (s)
    0: digit       = {1'b0, x[ 3: 0]};
    1: digit       = {1'b0, x[ 7: 4]};
    2: digit       = {1'b0, x[11: 8]};
    3: digit       = {1'b0, x[15:12]};
    4: digit       = 5'b1_0000;
    5: digit       = 5'b1_0001;
    6: digit       = 5'b1_0010;
    7: digit       = 5'b1_0011;
    default: digit = {1'b0, x[ 3: 0]};
endcase
```
In this case, we use `{1'b0, x}` to represent the highest score we get, and `{1'b1, ...}` to represent the characters we defined.

---

## Seg_disp
Then, we can display different characters according to the digit:
```verilog
case (digit)
    // 0 to F
    0:    SEGMENT = 7'b1000000;
    1:    SEGMENT = 7'b1111001;
    2:    SEGMENT = 7'b0100100;
    . . .
    'hE:  SEGMENT = 7'b0000110;
    'hF:  SEGMENT = 7'b0001110;
    // User defined character
    'h10: SEGMENT = 7'b0001011;	// h
    'h11: SEGMENT = 7'b0010000;	// g
    'h12: SEGMENT = 7'b1111001;	// I
    'h13: SEGMENT = 7'b0001001;	// H
endcase
```

---

![](https://github.com/Fairyland0902/BlockyRoads/raw/master/pics/Segment.jpeg)

---

# Renderer

---

# Components
- Layers for different objects
- Real-time rendering of the scrolling road

---

## Layers

1. **Layer 0**: Game-over prompt, score and digits *(in TERMINATE status)*
2. **Layer 1**: Explosion animation *(in ACTIVATE/PAUSE/TERMINATE status)*
3. **Layer 2**: My car and other obstacles *(in ACTIVATE/PAUSE/TERMINATE status)*
4. **Layer 3**: Road, sildes and side *(in ACTIVATE/PAUSE/TERMINATE status) OR background and start button (in PREPARE status)*

---

## Layers
### Background Color Filter
- Pseudo code:
```verilog
  if (object_pos)
  begin
      if (object_data == background color)
    	Render next layer
      else
      	Render this object
  end
```

---

## Layers
### General Procedure of Rendering
- Pseudo code:
```verilog
  if (layer0)
  begin
      if (object0_pos)
          Color filter and render this object
      if (object1_pos)
          Color filter and render this object
      . . .
  end
  if (layer1)
      . . .
```

---

## Scrolling Road
First, we need to pick out the **static** parts and **dynamic** parts of the image:
- **Static parts**:
2 EDGE lines
- **Dynamic parts**:
4 dot lines

---

## Scrolling Road
Then,we can have the basic structure of the code:
```verilog
if (EDGE lines' pos)
begin
    rgb <= line's color;
end
else if (dot lines' pos)
begin
    . . .
end
else
begin
    rgb <= background's color;
end
```

---

## Scrolling Road
In order to render the dot lines, we declare some variables and constants to represent the position of each dot:
```verilog
parameter slide_y  = 40;
parameter interval = 20;
integer i;
wire [9:0] dot_y;
assign dot_y = (pixel_y + scroll) % 480;
```
In this case, `scroll` is a variable that will change with time.

---

## Scrolling Road
With all the preparation, we can use a `for` loop to implement it:
```verilog
for (i = 0; i < 480; i = i + slide_y + interval)
begin
    if (dot_y >= i && dot_y < i + slide_y)
    begin
	    rgb <= dot's color;
    end
    else if (dot_y >= i + slide_y &&
             dot_y < i + slide_y + interval)
    begin
        rgb <= road's color;
    end
end
```

---

# Controller

---

# Components
- Collision Detector
- Random Generator

---

## Collision Detector

To simplify the detection procedure, we just detect the four vertices of the car position rectangle.

Then, we get the four follwing situations:

---

![](https://github.com/Fairyland0902/BlockyRoads/raw/master/pics/Collision_Detector.png)

---

## Random Generator

In order to generate a random number, the idea is as follows:
1. set time as the seed
2. use a counter to follow the change of time
3. When the user presses a key, generate a perturbation to disturb the counting circuit
4. Mod a prime number (such as 5) to make the reuslt more discrete

---

## Random Generator

- Pseudo code:
```verilog
if (key pressed)
    cnt <= cnt + 1023；
else
    cnt <= cnt + 1;

result = cnt % 5;
```




