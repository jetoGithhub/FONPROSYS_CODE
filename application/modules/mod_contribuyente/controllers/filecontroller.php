<?php
 
class Filecontroller extends CI_Controller {
 
    private $max_size = 1024;

    public function __construct() {
        parent::__construct();
        $this->load->library(array('upload', 'form_validation'));
        $this->load->helper(array('form', 'string'));
        $this->load->model('temporal');
       
    }
 
    function documentos() {
        $datos['lista_img']=$this->temporal->busca_archivos_contribu($this->session->userdata('id'));
        $listado['total']=$this->load->view('lista_archivos_contribu_v',$datos,true);
        $this->load->view('sube_archivos',$listado);

    }
  
    function lista_documentos() {
		
        $datos['lista_img']=$this->temporal->busca_archivos_contribu($this->session->userdata('id'));
        
        $this->load->view('lista_archivos_contribu_v',$datos);
    }
    
    /* Funcion para listar los documentos que fueron cargados por el contribuyente, 
     * en el backend. En la opción de Ver Documentos en el listar de las activaciones
     */
    function lista_documentos_backend($id_contribuyente) {
		
        $datos['lista_img']=$this->temporal->busca_archivos_contribu($id_contribuyente);
        
        $this->load->view('mod_gestioncontribuyente/lista_archivos_contribu_backend_v',$datos);
    }
    
    function subir_archivo() {
//        sleep(5);
        $estatus = '';
        $message = '';
        $background = '';
        $nombre_elemento_archivo = 'archivo_adjunto';
        if ($estatus != 'error') {
            //Ruta donde se guarda la imagen completa
            $configuracion['upload_path'] = './archivos/contribuyente/documentos_planilla/';
            //$configuracion['allowed_types'] = 'gif|jpg|png|doc|docx|pdf|txt|xsl|xslx|html|odf|rar|zip|7zip';
            $configuracion['allowed_types'] = '*';//Formatos permitidos
            $configuracion['max_size'] = $this->max_size * 8;
            $configuracion['overwrite'] = FALSE;
            $configuracion['encrypt_name'] = TRUE;
            $configuracion['remove_spaces'] = TRUE;
            $this->upload->initialize($configuracion);
            
            //Se verifica si el archivo fue cargado al servidor
            if (!$this->upload->do_upload($nombre_elemento_archivo)) {    
                    $estatus = false;
                    $mensaje = $this->upload->display_errors('', '');
                    
                } else {
                    $data = $this->upload->data();
                    $this->_crear_imagen_miniatura($data['file_name']);
                    $data_imagen = array(
                        'conusuid'      => $this->session->userdata('id'),
                        'descripcion'   => $this->input->post('title'),
                        'usuarioid'     =>$this->session->userdata('id'),
                        'ip'            =>$this->input->ip_address(),
                        'ruta_imagen'   => $data['file_name']);
                    
                    //Se guarda los datos del archivo en BD
                    $subir = $this->temporal->guarda_imagen($data_imagen);                            
                    
                    if ($subir) {  // Archivo agregado correctamente a la BD
                        $estatus = true;
                        $mensaje = 'Archivo subido correctamente';
                        
                    
                    } else {    // Si no fue agregado
                        unlink($configuracion['upload_path'].$data['file_name']); #borra archivo
                        $estatus = false;
                        $mensaje = 'No se pudo adjuntar el archivo';
                        
                    }
                }
                @unlink($_FILES[$nombre_elemento_archivo]);
            }
        
        $json_encode = json_encode(array('mensaje' => $mensaje, 'estatus' => $estatus, 'background' => $background));
        print($json_encode);
    }
    
    
    function _crear_imagen_miniatura($filename){
        $configuracion['image_library'] = 'gd2';
        //CARPETA EN LA QUE ESTÁ LA IMAGEN A REDIMENSIONAR
        $configuracion['source_image'] = './archivos/contribuyente/documentos_planilla/'.$filename;
        $configuracion['create_thumb'] = TRUE;
        $configuracion['maintain_ratio'] = TRUE;
        //CARPETA EN LA QUE GUARDAMOS LA MINIATURA
        $configuracion['new_image']='./archivos/contribuyente/documentos_planilla/miniaturas/';
        $configuracion['width'] = 60;
        $configuracion['height'] = 60;
        $this->load->library('image_lib', $configuracion);
        $this->image_lib->resize();
    }
    function archivo_elimina($id){
//        sleep(5);
        
        if ($this->temporal->elimina_archivo($id)):
            $data=array(
                'success' =>true,
                'mensaje' =>'archivo eliminado exitosamente!'
                );
        else:
            $data=array(
                'success' =>true,
                'mensaje' =>'No se pudo eliminar el archivo!'
                );            
        endif;
        print(json_encode($data));
    }
    function borrado_accionista($id){
//        sleep(5);
        if ($this->temporal->elimina_accionista($id)):
            $data=array(
                'success' =>true,
                'mensaje' =>'Registro eliminado exitosamente!'
                );
        else:
            $data=array(
                'success' =>true,
                'mensaje' =>'No se pudo eliminar el registro!'
                );            
        endif;
        
        print(json_encode($data));        
    }
}
?>
