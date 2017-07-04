//
import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    //Outlets da interface
    @IBOutlet weak var btShare: UIButton!
    @IBOutlet weak var btSalvar: UIButton!
    @IBOutlet weak var btFiltro: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var sliderIntensidade: UISlider!
    @IBOutlet weak var labelIntensidade: UILabel!
    
    var imagemAtual: UIImage!
    var context: CIContext!
    var filtroAtual: CIFilter!
    
    //Função para o Pré-carregamento
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setta titulo do APP
        title = "BeautFilter"

        //Mostra o botão de Adicionar (+) no topo direito da tela
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ViewController.importarImg))
        
        context = CIContext(options: nil)
        
        //Setta como filtro default o Sepia
        filtroAtual = CIFilter(name: "CISepiaTone")
        
        //Esconde barra slider
        sliderIntensidade.isHidden = true
        labelIntensidade.isHidden = true
    }

    //Função para iniciar ação de importar uma imagem do dispositivo para o APP
    func importarImg(){
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
        
    }
    
    //Função responsavel por manipular a importação da imagem para o APP
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var novaImg: UIImage
        
        
        if let possibleImg = info["UIImagePickerControllerEditedImage"] as? UIImage {
            novaImg = possibleImg
        }
        else if let possibleImg = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            novaImg = possibleImg
        }
        else { //Caso o usuario cancelou a operação de importação, retorna
            return
        }
        
        dismiss(animated: true, completion: nil) //Fecha a modal de importação
        
        imagemAtual = novaImg
        
        //Aplica o filtro atual na imagem importada
        let imagemInicial = CIImage(image: imagemAtual)
        filtroAtual.setValue(imagemInicial, forKey: kCIInputImageKey)
        
        //Habilita os botões da interface
        btFiltro.isEnabled = true
        btSalvar.isEnabled = true
        btShare.isEnabled = true
        sliderIntensidade.isHidden = false
        labelIntensidade.isHidden = false
        
        //Aplica as variações do filtro na imagem importada
        processarImagem()
        //imageView.image = imagemAtual
    }
    
    //Se o usuario cancelar a ação de importar imagem
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //Função para mostrar o alert contendo todos os filtros
    @IBAction func TrocaFiltro(_ sender: Any) {
        
        let alert = UIAlertController(title: "Escolha um filtro", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFiltro))
        alert.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFiltro))
        alert.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFiltro))
        alert.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFiltro))
        alert.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFiltro))
        alert.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFiltro))
        alert.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFiltro))
        alert.addAction(UIAlertAction(title: "Fechar", style: .cancel, handler: nil))
        
        //Exibir alert
        present(alert, animated: true, completion: nil)
    }
    
    //Função para settar o novo filtro escolhido
    func setFiltro(action: UIAlertAction!)
    {
        filtroAtual = CIFilter(name: action!.title!)
        
        let imagemInicial = CIImage(image: imagemAtual)
        filtroAtual.setValue(imagemInicial, forKey: kCIInputImageKey)
        
        processarImagem()
    }

    //Função responsável por iniciar o processo de salvar a imagem na memória do dispositivo
    @IBAction func SalvaImagem(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(imageView!.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    //Tratar o resultado de salvamento da imagem
    func image(_ image:UIImage, didFinishSavingWithError error:NSError?, contextInfo: UnsafeRawPointer)
    {
        //Exibir alert de sucesso
        if error == nil
        {
            let alert = UIAlertController(title: "Sucesso!", message: "Sua foto foi salva com sucesso", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        else //Exibir alert de erro
        {
            let alert = UIAlertController(title: "Erro", message: error?.localizedDescription, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)

        }
    }
    
    //Função que manipula o valor da barra de intesidade do filtro
    @IBAction func MudaIntesidade(_ sender: Any) {
        processarImagem()
    }
    
    //Manipulação dos valores da intensidade em relações aos tipos filtros
    func processarImagem(){
        
        let inputKeys = filtroAtual.inputKeys as [NSString]
        
        //Para cada tipo de filtro, tratar a intensidade
        
        //Sepia e Vignette
        if inputKeys.contains(kCIInputIntensityKey as NSString)
        {
            filtroAtual.setValue(sliderIntensidade.value, forKey: kCIInputIntensityKey)
        }
        
        //Pixel
        if inputKeys.contains(kCIInputScaleKey as NSString)
        {
            filtroAtual.setValue(sliderIntensidade.value * 10, forKey: kCIInputScaleKey)
        }
        
        //Gaussian, Twirl e Unsharp
        if inputKeys.contains(kCIInputRadiusKey as NSString)
        {
            filtroAtual.setValue(sliderIntensidade.value * 200, forKey: kCIInputRadiusKey)
        }
        
        //Bump
        if inputKeys.contains(kCIInputCenterKey as NSString)
        {
            filtroAtual.setValue(CIVector(x: imagemAtual.size.width / 2.0, y: imagemAtual.size.height / 2.0), forKey: kCIInputCenterKey)
        }
        
        //Transformar a imagem
        let cgimg = context.createCGImage(filtroAtual.outputImage!, from: filtroAtual.outputImage!.extent)
        let imgProcessada = UIImage(cgImage: cgimg!)
    
        //Diplay na nova imagem
        imageView.image = imgProcessada
    }
    
    //Ação do botão de compartilhamento da imagem
    @IBAction func compartilhar(_ sender: Any) {
        
        let message = "Foto estilizada com BeautFilter"
        
        //Objetos a compartilhar: Mensagem default e imagem
        let objectsToShare = [message,imageView.image!] as [Any]
        
        
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
        
        //Mostrar barra de compartilhamento nativa
        self.present(activityVC, animated: true, completion: nil)
        
    }

}

