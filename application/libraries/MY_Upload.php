<?php 
class My_Upload extends CI_Upload 
{     
     public function __construct()
    {
        parent::__construct();
    }
    
    // --------------------------------------------------------------------

	/**
	 * Perform the file upload
	 *
	 * @return	bool
	 */
	public function do_upload_write_server($nombre_elemento_archivo)
	{
            if (!$this->upload->do_upload($nombre_elemento_archivo)) { 
                
                return FALSE;
                
            }else{
                
                return TRUE;
            }
	
	}
    
}