{
    Copyright 2021 by Mogens Bramm

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
}

program i2c;

const
  DEVICE_RD = $7F;
  DEVICE_WR = $7E;
  LOW       = 0;
  HIGH      = 1;
  I2C_PORT  = $0C;
  SDA_MASK  = $80;
  SDA_BIT   = 7;

  function getState: byte;
  begin
    getState := (port[I2C_PORT] shr SDA_BIT) and $01;
  end;

  procedure setState(sda, sdc: byte);
  begin
    port[I2C_PORT] := (sda shl SDA_BIT) or sdc;
  end;

  function readBit: byte;
  begin
    setState(HIGH, LOW);
    setState(HIGH, HIGH);
    readBit := getState;
  end;

  procedure writeBit(sda: byte);
  begin
    setState(sda, LOW);
    setState(sda, HIGH);
  end;

  function readByte(ack: byte): byte;
  var i, b: byte;
  begin
    b := 0;
    for i := 0 to 7 do begin
      b := b shl 1;
      b := b or readBit;
    end;
    writeBit(ack);
    readByte := b;
  end;

  function writeByte(b: byte): byte;
  var i: byte;
  begin
    for i := 0 to 7 do begin
      if b and $80 = 0 then
        writeBit(LOW)
      else
        writeBit(HIGH);
      b := b shl 1;
    end;
    writeByte := readBit; { return ACK/NACK value }
  end;

  procedure startSequence;
  begin
    setState(HIGH, HIGH);
    setState(LOW, HIGH);
    setState(LOW, LOW);
  end;

  procedure endSequence;
  begin
    setState(LOW, LOW);
    setState(LOW, HIGH);
    setState(HIGH, HIGH);
  end;

var
  i: byte;
  ack: byte;
  buttons: byte;

begin
  writeln('Read the SC407 buttons 8 times - enough to test each button once.');
  for i := 0 to 7 do begin
    write('Press enter to READ from SC407 I2C bus'); readln;
    startSequence;
    ack := writeByte(DEVICE_RD);
    buttons := readByte(HIGH);
    endSequence;
    writeln('Button state: ', buttons);
  end;

  writeln('Write the SC407 LEDs - counts from 0 to 255.');
  write('Press enter to WRITE to SC407 I2C bus'); readln;
  startSequence;
  ack := writeByte(DEVICE_WR);
  for i := 0 to 255 do begin
    ack := writeByte(i);
  end;
  endSequence;
end.
