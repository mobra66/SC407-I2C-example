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

program sc407;

{$I I2CLIB.PAS}

const
  DEVICE_RD = $7F;
  DEVICE_WR = $7E;
  ACK       = $00;
  NACK      = $01;

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
