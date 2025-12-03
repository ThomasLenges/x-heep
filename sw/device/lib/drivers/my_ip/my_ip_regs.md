<table class="regdef" id="Reg_intr_state">
 <tr>
  <th class="regdef" colspan=5>
   <div>my_ip.INTR_STATE @ 0x0</div>
   <div><p>Interrupt State Register</p></div>
   <div>Reset default = 0x0, mask 0x1</div>
  </th>
 </tr>
<tr><td colspan=5><table class="regpic"><tr><td class="bitnum">31</td><td class="bitnum">30</td><td class="bitnum">29</td><td class="bitnum">28</td><td class="bitnum">27</td><td class="bitnum">26</td><td class="bitnum">25</td><td class="bitnum">24</td><td class="bitnum">23</td><td class="bitnum">22</td><td class="bitnum">21</td><td class="bitnum">20</td><td class="bitnum">19</td><td class="bitnum">18</td><td class="bitnum">17</td><td class="bitnum">16</td></tr><tr><td class="unused" colspan=16>&nbsp;</td>
</tr>
<tr><td class="bitnum">15</td><td class="bitnum">14</td><td class="bitnum">13</td><td class="bitnum">12</td><td class="bitnum">11</td><td class="bitnum">10</td><td class="bitnum">9</td><td class="bitnum">8</td><td class="bitnum">7</td><td class="bitnum">6</td><td class="bitnum">5</td><td class="bitnum">4</td><td class="bitnum">3</td><td class="bitnum">2</td><td class="bitnum">1</td><td class="bitnum">0</td></tr><tr><td class="unused" colspan=15>&nbsp;</td>
<td class="fname" colspan=1 style="font-size:27.272727272727273%">my_ip_event</td>
</tr></table></td></tr>
<tr><th width=5%>Bits</th><th width=5%>Type</th><th width=5%>Reset</th><th>Name</th><th>Description</th></tr><tr><td class="regbits">0</td><td class="regperm">rw1c</td><td class="regrv">0x0</td><td class="regfn">my_ip_event</td><td class="regde"><p>Event-related interrupts.</p></td></table>
<br>
<table class="regdef" id="Reg_intr_enable">
 <tr>
  <th class="regdef" colspan=5>
   <div>my_ip.INTR_ENABLE @ 0x4</div>
   <div><p>Interrupt Enable Register</p></div>
   <div>Reset default = 0x0, mask 0x1</div>
  </th>
 </tr>
<tr><td colspan=5><table class="regpic"><tr><td class="bitnum">31</td><td class="bitnum">30</td><td class="bitnum">29</td><td class="bitnum">28</td><td class="bitnum">27</td><td class="bitnum">26</td><td class="bitnum">25</td><td class="bitnum">24</td><td class="bitnum">23</td><td class="bitnum">22</td><td class="bitnum">21</td><td class="bitnum">20</td><td class="bitnum">19</td><td class="bitnum">18</td><td class="bitnum">17</td><td class="bitnum">16</td></tr><tr><td class="unused" colspan=16>&nbsp;</td>
</tr>
<tr><td class="bitnum">15</td><td class="bitnum">14</td><td class="bitnum">13</td><td class="bitnum">12</td><td class="bitnum">11</td><td class="bitnum">10</td><td class="bitnum">9</td><td class="bitnum">8</td><td class="bitnum">7</td><td class="bitnum">6</td><td class="bitnum">5</td><td class="bitnum">4</td><td class="bitnum">3</td><td class="bitnum">2</td><td class="bitnum">1</td><td class="bitnum">0</td></tr><tr><td class="unused" colspan=15>&nbsp;</td>
<td class="fname" colspan=1 style="font-size:27.272727272727273%">my_ip_event</td>
</tr></table></td></tr>
<tr><th width=5%>Bits</th><th width=5%>Type</th><th width=5%>Reset</th><th>Name</th><th>Description</th></tr><tr><td class="regbits">0</td><td class="regperm">rw</td><td class="regrv">0x0</td><td class="regfn">my_ip_event</td><td class="regde"><p>Enable interrupt when <a href="#Reg_intr_state"><code class="reg">INTR_STATE.my_ip_event</code></a> is set.</p></td></table>
<br>
<table class="regdef" id="Reg_intr_test">
 <tr>
  <th class="regdef" colspan=5>
   <div>my_ip.INTR_TEST @ 0x8</div>
   <div><p>Interrupt Test Register</p></div>
   <div>Reset default = 0x0, mask 0x1</div>
  </th>
 </tr>
<tr><td colspan=5><table class="regpic"><tr><td class="bitnum">31</td><td class="bitnum">30</td><td class="bitnum">29</td><td class="bitnum">28</td><td class="bitnum">27</td><td class="bitnum">26</td><td class="bitnum">25</td><td class="bitnum">24</td><td class="bitnum">23</td><td class="bitnum">22</td><td class="bitnum">21</td><td class="bitnum">20</td><td class="bitnum">19</td><td class="bitnum">18</td><td class="bitnum">17</td><td class="bitnum">16</td></tr><tr><td class="unused" colspan=16>&nbsp;</td>
</tr>
<tr><td class="bitnum">15</td><td class="bitnum">14</td><td class="bitnum">13</td><td class="bitnum">12</td><td class="bitnum">11</td><td class="bitnum">10</td><td class="bitnum">9</td><td class="bitnum">8</td><td class="bitnum">7</td><td class="bitnum">6</td><td class="bitnum">5</td><td class="bitnum">4</td><td class="bitnum">3</td><td class="bitnum">2</td><td class="bitnum">1</td><td class="bitnum">0</td></tr><tr><td class="unused" colspan=15>&nbsp;</td>
<td class="fname" colspan=1 style="font-size:27.272727272727273%">my_ip_event</td>
</tr></table></td></tr>
<tr><th width=5%>Bits</th><th width=5%>Type</th><th width=5%>Reset</th><th>Name</th><th>Description</th></tr><tr><td class="regbits">0</td><td class="regperm">wo</td><td class="regrv">0x0</td><td class="regfn">my_ip_event</td><td class="regde"><p>Write 1 to force <a href="#Reg_intr_state"><code class="reg">INTR_STATE.my_ip_event</code></a> to 1.</p></td></table>
<br>
<table class="regdef" id="Reg_control">
 <tr>
  <th class="regdef" colspan=5>
   <div>my_ip.CONTROL @ 0xc</div>
   <div><p>Control register for flash controller</p></div>
   <div>Reset default = 0x0, mask 0x3</div>
  </th>
 </tr>
<tr><td colspan=5><table class="regpic"><tr><td class="bitnum">31</td><td class="bitnum">30</td><td class="bitnum">29</td><td class="bitnum">28</td><td class="bitnum">27</td><td class="bitnum">26</td><td class="bitnum">25</td><td class="bitnum">24</td><td class="bitnum">23</td><td class="bitnum">22</td><td class="bitnum">21</td><td class="bitnum">20</td><td class="bitnum">19</td><td class="bitnum">18</td><td class="bitnum">17</td><td class="bitnum">16</td></tr><tr><td class="unused" colspan=16>&nbsp;</td>
</tr>
<tr><td class="bitnum">15</td><td class="bitnum">14</td><td class="bitnum">13</td><td class="bitnum">12</td><td class="bitnum">11</td><td class="bitnum">10</td><td class="bitnum">9</td><td class="bitnum">8</td><td class="bitnum">7</td><td class="bitnum">6</td><td class="bitnum">5</td><td class="bitnum">4</td><td class="bitnum">3</td><td class="bitnum">2</td><td class="bitnum">1</td><td class="bitnum">0</td></tr><tr><td class="unused" colspan=14>&nbsp;</td>
<td class="fname" colspan=1>RNW</td>
<td class="fname" colspan=1 style="font-size:60.0%">START</td>
</tr></table></td></tr>
<tr><th width=5%>Bits</th><th width=5%>Type</th><th width=5%>Reset</th><th>Name</th><th>Description</th></tr><tr><td class="regbits">0</td><td class="regperm">rw</td><td class="regrv">0x0</td><td class="regfn">START</td><td class="regde"><p>Start action</p></td><tr><td class="regbits">1</td><td class="regperm">rw</td><td class="regrv">0x0</td><td class="regfn">RNW</td><td class="regde"><p>read not write</p></td></table>
<br>
<table class="regdef" id="Reg_status">
 <tr>
  <th class="regdef" colspan=5>
   <div>my_ip.STATUS @ 0x10</div>
   <div><p>Status register for flash controller</p></div>
   <div>Reset default = 0x0, mask 0x1</div>
  </th>
 </tr>
<tr><td colspan=5><table class="regpic"><tr><td class="bitnum">31</td><td class="bitnum">30</td><td class="bitnum">29</td><td class="bitnum">28</td><td class="bitnum">27</td><td class="bitnum">26</td><td class="bitnum">25</td><td class="bitnum">24</td><td class="bitnum">23</td><td class="bitnum">22</td><td class="bitnum">21</td><td class="bitnum">20</td><td class="bitnum">19</td><td class="bitnum">18</td><td class="bitnum">17</td><td class="bitnum">16</td></tr><tr><td class="unused" colspan=16>&nbsp;</td>
</tr>
<tr><td class="bitnum">15</td><td class="bitnum">14</td><td class="bitnum">13</td><td class="bitnum">12</td><td class="bitnum">11</td><td class="bitnum">10</td><td class="bitnum">9</td><td class="bitnum">8</td><td class="bitnum">7</td><td class="bitnum">6</td><td class="bitnum">5</td><td class="bitnum">4</td><td class="bitnum">3</td><td class="bitnum">2</td><td class="bitnum">1</td><td class="bitnum">0</td></tr><tr><td class="unused" colspan=15>&nbsp;</td>
<td class="fname" colspan=1 style="font-size:60.0%">READY</td>
</tr></table></td></tr>
<tr><th width=5%>Bits</th><th width=5%>Type</th><th width=5%>Reset</th><th>Name</th><th>Description</th></tr><tr><td class="regbits">0</td><td class="regperm">rw</td><td class="regrv">0x0</td><td class="regfn">READY</td><td class="regde"><p>Ready for new read/write</p></td></table>
<br>
<table class="regdef" id="Reg_r_address">
 <tr>
  <th class="regdef" colspan=5>
   <div>my_ip.R_ADDRESS @ 0x14</div>
   <div><p>Address in Flash to read from/write to</p></div>
   <div>Reset default = 0x0, mask 0xffffffff</div>
  </th>
 </tr>
<tr><td colspan=5><table class="regpic"><tr><td class="bitnum">31</td><td class="bitnum">30</td><td class="bitnum">29</td><td class="bitnum">28</td><td class="bitnum">27</td><td class="bitnum">26</td><td class="bitnum">25</td><td class="bitnum">24</td><td class="bitnum">23</td><td class="bitnum">22</td><td class="bitnum">21</td><td class="bitnum">20</td><td class="bitnum">19</td><td class="bitnum">18</td><td class="bitnum">17</td><td class="bitnum">16</td></tr><tr><td class="fname" colspan=16>R_ADDRESS...</td>
</tr>
<tr><td class="bitnum">15</td><td class="bitnum">14</td><td class="bitnum">13</td><td class="bitnum">12</td><td class="bitnum">11</td><td class="bitnum">10</td><td class="bitnum">9</td><td class="bitnum">8</td><td class="bitnum">7</td><td class="bitnum">6</td><td class="bitnum">5</td><td class="bitnum">4</td><td class="bitnum">3</td><td class="bitnum">2</td><td class="bitnum">1</td><td class="bitnum">0</td></tr><tr><td class="fname" colspan=16>...R_ADDRESS</td>
</tr></table></td></tr>
<tr><th width=5%>Bits</th><th width=5%>Type</th><th width=5%>Reset</th><th>Name</th><th>Description</th></tr><tr><td class="regbits">31:0</td><td class="regperm">rw</td><td class="regrv">x</td><td class="regfn">R_ADDRESS</td><td class="regde"><p>Address to read from</p></td></table>
<br>
<table class="regdef" id="Reg_s_address">
 <tr>
  <th class="regdef" colspan=5>
   <div>my_ip.S_ADDRESS @ 0x18</div>
   <div><p>Address to store read data from SPI_FLASH</p></div>
   <div>Reset default = 0x0, mask 0xffffffff</div>
  </th>
 </tr>
<tr><td colspan=5><table class="regpic"><tr><td class="bitnum">31</td><td class="bitnum">30</td><td class="bitnum">29</td><td class="bitnum">28</td><td class="bitnum">27</td><td class="bitnum">26</td><td class="bitnum">25</td><td class="bitnum">24</td><td class="bitnum">23</td><td class="bitnum">22</td><td class="bitnum">21</td><td class="bitnum">20</td><td class="bitnum">19</td><td class="bitnum">18</td><td class="bitnum">17</td><td class="bitnum">16</td></tr><tr><td class="fname" colspan=16>S_ADDRESS...</td>
</tr>
<tr><td class="bitnum">15</td><td class="bitnum">14</td><td class="bitnum">13</td><td class="bitnum">12</td><td class="bitnum">11</td><td class="bitnum">10</td><td class="bitnum">9</td><td class="bitnum">8</td><td class="bitnum">7</td><td class="bitnum">6</td><td class="bitnum">5</td><td class="bitnum">4</td><td class="bitnum">3</td><td class="bitnum">2</td><td class="bitnum">1</td><td class="bitnum">0</td></tr><tr><td class="fname" colspan=16>...S_ADDRESS</td>
</tr></table></td></tr>
<tr><th width=5%>Bits</th><th width=5%>Type</th><th width=5%>Reset</th><th>Name</th><th>Description</th></tr><tr><td class="regbits">31:0</td><td class="regperm">rw</td><td class="regrv">x</td><td class="regfn">S_ADDRESS</td><td class="regde"><p>Address to store read data from SPI_FLASH</p></td></table>
<br>
<table class="regdef" id="Reg_md_address">
 <tr>
  <th class="regdef" colspan=5>
   <div>my_ip.MD_ADDRESS @ 0x1c</div>
   <div><p>Address where data with which we have to modify the flash is</p></div>
   <div>Reset default = 0x0, mask 0xffffffff</div>
  </th>
 </tr>
<tr><td colspan=5><table class="regpic"><tr><td class="bitnum">31</td><td class="bitnum">30</td><td class="bitnum">29</td><td class="bitnum">28</td><td class="bitnum">27</td><td class="bitnum">26</td><td class="bitnum">25</td><td class="bitnum">24</td><td class="bitnum">23</td><td class="bitnum">22</td><td class="bitnum">21</td><td class="bitnum">20</td><td class="bitnum">19</td><td class="bitnum">18</td><td class="bitnum">17</td><td class="bitnum">16</td></tr><tr><td class="fname" colspan=16>MD_ADDRESS...</td>
</tr>
<tr><td class="bitnum">15</td><td class="bitnum">14</td><td class="bitnum">13</td><td class="bitnum">12</td><td class="bitnum">11</td><td class="bitnum">10</td><td class="bitnum">9</td><td class="bitnum">8</td><td class="bitnum">7</td><td class="bitnum">6</td><td class="bitnum">5</td><td class="bitnum">4</td><td class="bitnum">3</td><td class="bitnum">2</td><td class="bitnum">1</td><td class="bitnum">0</td></tr><tr><td class="fname" colspan=16>...MD_ADDRESS</td>
</tr></table></td></tr>
<tr><th width=5%>Bits</th><th width=5%>Type</th><th width=5%>Reset</th><th>Name</th><th>Description</th></tr><tr><td class="regbits">31:0</td><td class="regperm">rw</td><td class="regrv">x</td><td class="regfn">MD_ADDRESS</td><td class="regde"><p>Address where data with which we have to modify the flash is</p></td></table>
<br>
<table class="regdef" id="Reg_length">
 <tr>
  <th class="regdef" colspan=5>
   <div>my_ip.LENGTH @ 0x20</div>
   <div><p>Length of data to W/R</p></div>
   <div>Reset default = 0x0, mask 0xffffffff</div>
  </th>
 </tr>
<tr><td colspan=5><table class="regpic"><tr><td class="bitnum">31</td><td class="bitnum">30</td><td class="bitnum">29</td><td class="bitnum">28</td><td class="bitnum">27</td><td class="bitnum">26</td><td class="bitnum">25</td><td class="bitnum">24</td><td class="bitnum">23</td><td class="bitnum">22</td><td class="bitnum">21</td><td class="bitnum">20</td><td class="bitnum">19</td><td class="bitnum">18</td><td class="bitnum">17</td><td class="bitnum">16</td></tr><tr><td class="fname" colspan=16>LENGTH...</td>
</tr>
<tr><td class="bitnum">15</td><td class="bitnum">14</td><td class="bitnum">13</td><td class="bitnum">12</td><td class="bitnum">11</td><td class="bitnum">10</td><td class="bitnum">9</td><td class="bitnum">8</td><td class="bitnum">7</td><td class="bitnum">6</td><td class="bitnum">5</td><td class="bitnum">4</td><td class="bitnum">3</td><td class="bitnum">2</td><td class="bitnum">1</td><td class="bitnum">0</td></tr><tr><td class="fname" colspan=16>...LENGTH</td>
</tr></table></td></tr>
<tr><th width=5%>Bits</th><th width=5%>Type</th><th width=5%>Reset</th><th>Name</th><th>Description</th></tr><tr><td class="regbits">31:0</td><td class="regperm">rw</td><td class="regrv">x</td><td class="regfn">LENGTH</td><td class="regde"><p>Length of data to W/R</p></td></table>
<br>
