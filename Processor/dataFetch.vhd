LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use work.MIPSCPU_constants.ALL;

ENTITY dataFetch IS
PORT(
	clk : in std_logic;
	nextAddress : in integer := 0;
	instruction : out std_logic_vector(register_size downto 0);
	instReady : out std_logic := '0';
	fetchNext : in std_logic := '1';
	readOrWrite : in std_logic := '1';
	dataToWrite : out std_logic_vector(register_size downto 0);
	output : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	writeSuccess : out std_logic :='0'
);
END dataFetch;

ARCHITECTURE behavior OF dataFetch IS
	type state_type is (init, read_mem1, read_mem2, write_mem1, sdump,waiting);
	Constant Num_Bits_in_Byte: integer := 8; 
	Constant Num_Bytes_in_Word: integer := 4; 
	Constant Memory_Size: integer := 256; 
	COMPONENT Main_Memory
	generic (
			File_Address_Read : string :="DataInit.dat";
			File_Address_Write : string :="DataMemCon.dat";
			Mem_Size_in_Word : integer:=256;	
			Num_Bytes_in_Word: integer:=4;
			Num_Bits_in_Byte: integer := 8; 
			Read_Delay: integer:=0; 
			Write_Delay: integer:=0
		 );
   	 PORT(
			clk : IN  std_logic;
			address : IN  integer;
			Word_Byte: in std_logic;
			we : IN  std_logic;
			wr_done : OUT  std_logic;
			re : IN  std_logic;
			rd_ready : OUT  std_logic;
			data : INOUT  std_logic_vector(Num_Bytes_in_Word*Num_Bits_in_Byte-1 downto 0);
			initialize : IN  std_logic;
			dump : IN  std_logic
        );
    	END COMPONENT;
    
	
   --Inputs
   signal address : integer := 0;
   signal we : std_logic := '0';
   signal re : std_logic := '0';
   signal data : std_logic_vector(Num_Bytes_in_Word*Num_Bits_in_Byte-1 downto 0) := (others => 'Z');
   signal initialize : std_logic := '0';
   signal dump : std_logic := '0';

   signal wr_done : std_logic;
   signal rd_ready : std_logic;
	
	-- Tests Simulation State 
	signal state:	state_type:=init;
 
BEGIN
   main_mem: Main_Memory 
	generic map (
			File_Address_Read =>"DataInit.dat",
			File_Address_Write =>"DataMemCon.dat",
			Mem_Size_in_Word =>256,
			Num_Bytes_in_Word=>4,
			Num_Bits_in_Byte=>8,
			Read_Delay=>0,
			Write_Delay=>0
		 )
		PORT MAP (
          clk => clk,
          address => address,
          Word_Byte => '0',
          we => we,
          wr_done => wr_done,
          re => re,
          rd_ready => rd_ready,
          data => data,          
          initialize => initialize,
          dump => dump
        ); 

   -- Stimulus process
   stim_proc: process (clk)
   begin		
      if RISING_EDGE(clk) then
			data <= (others=>'Z');
			case state is
				when init =>
					initialize <= '1'; --triggerd.
					instReady <='0';
					state <= waiting;
				when waiting =>
					instReady <='0';
					writeSuccess <='0';
					initialize <= '0';
					address <= nextAddress;
					re<='0';
					we<='0';
					if(readOrWrite ='0' and fetchNext = '1') then
						state <= read_mem1;
					elsif(readOrWrite ='1' and fetchNext = '1') then
						state <= write_mem1;
					else 
						state <= waiting;
					end if;		
				when read_mem1 =>
					instReady <='0';
					we <='0';
					re <='1';
					initialize <= '0';
					dump <= '0';
					state <= read_mem2;
				when read_mem2 =>
					re <='1';
					if (rd_ready = '1') then -- the output is ready on the memory bus
						instruction <= data;
						output <= data(7 DOWNTO 0);
						address <= nextAddress;
						re <='0';
						instReady <='1';
						state <= waiting; --read finished go to test state write 
					else
						state <= read_mem2; -- stay in this state till you see rd_ready='1';
						instReady <='0';
					end if;
				when write_mem1 =>
					address <= nextAddress;
					we <='1';
					re <='0';
					initialize <= '0';
					dump <= '0';
					data <= dataToWrite;
					
					if (wr_done = '1') then -- the output is ready on the memory bus
						state <= sdump; --write finished go to the dump state
						writeSuccess <='1';
					else
						state <= write_mem1; -- stay in this state till you see rd_ready='1';
					end if;	
					
				when sdump =>
					initialize <= '0'; 
					re<='0';
					we<='0';
					dump <= '1'; --triggerd
					state <= waiting;
				when others =>
			end case;
		end if;
   end process;

END;