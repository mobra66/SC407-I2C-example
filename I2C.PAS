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
  SDA_LOW   = $00;
  SDA_HIGH  = $80;
  SCL_LOW   = $00;
  SCL_HIGH  = $01;
  ACK       = $00;
  NACK      = $80;
  I2C_PORT  = $0C;
  SDA_MASK  = $80;

  function getState: byte;
  begin
    getState := port[I2C_PORT] and SDA_MASK;
  end;

  procedure setState(sda, sdc: byte);
  begin
    port[I2C_PORT] := sda or sdc;
  end;

  function readBit: byte;
  begin
    setState(SDA_HIGH, SCL_LOW);
    setState(SDA_HIGH, SCL_HIGH);
    readBit := getState;
  end;

  procedure writeBit(sda: byte);
  begin
    setState(sda, SCL_LOW);
    setState(sda, SCL_HIGH);
  end;

  function readByte(ack: byte): byte;
  var i, b: byte;
  begin
    b := 0;
    for i := 0 to 7 do
      if readBit = SDA_HIGH then
        b := (b shl 1) or $01
      else
        b := b shl 1;
    writeBit(ack);
    readByte := b;
  end;

  function writeByte(b: byte): byte;
  var i: byte;
  begin
    for i := 0 to 7 do begin
      writeBit(b and SDA_MASK);
      b := b shl 1;
    end;
    writeByte := readBit; { return ACK/NACK value }
  end;

  procedure startSequence;
  begin
    setState(SDA_HIGH, SCL_HIGH);
    setState(SDA_LOW, SCL_HIGH);
    setState(SDA_LOW, SCL_LOW);
  end;

  procedure endSequence;
  begin
    setState(SDA_LOW, SCL_LOW);
    setState(SDA_LOW, SCL_HIGH);
    setState(SDA_HIGH, SCL_HIGH);
  end;

var
  i: byte;
  ack_nack: byte;
  buttons: byte;

begin
  writeln('Read the SC407 buttons 8 times - enough to test each button once.');
  for i := 0 to 7 do begin
    write('Press enter to READ from SC407 I2C bus'); readln;
    startSequence;
    ack_nack := writeByte(DEVICE_RD);
    buttons := readByte(NACK);
    endSequence;
    writeln('Button state: ', buttons);
  end;

  writeln('Write the SC407 LEDs - counts from 0 to 255.');
  write('Press enter to WRITE to SC407 I2C bus'); readln;
  startSequence;
  ack_nack := writeByte(DEVICE_WR);
  for i := 0 to 255 do begin
    ack_nack := writeByte(i);
  end;
  endSequence;
end.
