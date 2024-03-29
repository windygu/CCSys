﻿using LasMargaritas.BL;
using LasMargaritas.BL.Views;
using LasMargaritas.Models;
using System;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Windows.Controls;
using System.Collections.Generic;
using LasMargaritas.BL.Presenters;
using WebEye.Controls.Wpf;
using System.Linq;
using System.IO;    
using System.Drawing.Imaging;
using System.Drawing;
using System.Windows.Data;
using System.Windows;

namespace LasMargaritas.UI.UserControls
{
    /// <summary>
    /// Interaction logic for Login.xaml
    /// </summary>
    public partial class ProducerList : UserControl, IProducerView
    {
        #region Private variables
        private ProducerPresenter presenter;
        private List<SelectableModel> _Producers;
        private bool listLoaded;
        #endregion

        #region Public Properties
        public Token Token { get; set; }




        #endregion

        #region IProducerView implementation
        public Producer CurrentProducer { get; set; }
        
        public List<SelectableModel> States { get; set; }
        public List<SelectableModel> CivilStatus { get; set; }
        public List<SelectableModel> Regimes { get; set; }
        public List<SelectableModel> Genders { get; set; }

        public int SelectedId
        {
            get
            {
                if(ListBoxProducers.SelectedItem != null)
                {
                    return ((SelectableModel)ListBoxProducers.SelectedItem).Id;
                }
                return -1;
            }
            set
            {
                if (value <= 0)
                {

                    ListBoxProducers.SelectedValue = null;
                    ListBoxProducers.SelectedIndex = -1;
                }
                else
                {
                    foreach (var item in ListBoxProducers.Items)
                    {
                        if(((SelectableModel)item).Id == value)
                        {
                            ListBoxProducers.SelectedItem = item;
                            ListBoxProducers.ScrollIntoView(item);                            
                            break;
                        }
                    }
                }

            }
        }        

        public List<SelectableModel> Producers
        {
            get
            { 
                return _Producers;
            }
            set
            {
                _Producers = value;
                ListBoxProducers.ItemsSource = _Producers;
                CollectionView view = (CollectionView)CollectionViewSource.GetDefaultView(ListBoxProducers.ItemsSource);
                view.Filter = ProducerFilter;
            }
        }

        private bool ProducerFilter(object item)
        {
            if (string.IsNullOrEmpty(TextBoxSearchProducers.Text))
                return true;
            else
                return ((item as SelectableModel).Name != null && (item as SelectableModel).Name.IndexOf(TextBoxSearchProducers.Text, StringComparison.OrdinalIgnoreCase) >= 0)
                    || string.Compare(((item as SelectableModel).Id.ToString()), TextBoxSearchProducers.Text) == 0;
                       
        }


        public void HandleException(Exception ex, string method, Guid errorId)
        {
            string errorMessage = string.Empty;
            if(ex is ProducerException)
            {
                errorMessage = "Hubo un problema en la última acción. Detalles: - Producer Exception: " + ((ProducerException)ex).Error.ToString();
            }
            else if (ex is SelectableModelException)
            {
                errorMessage = "Hubo un problema en la última acción. Detalles: - SelectableModelException Exception: " + ((SelectableModelException)ex).Error.ToString();
            }
            else
            {
                errorMessage = "Hubo un problema en la última acción. Detalles: - Unknown Exception ";
            }
            errorMessage += ". " + ex.Message + ". Method: " + method;
            MessageBox.Show(errorMessage, "Error", MessageBoxButton.OK, MessageBoxImage.Error);
        }
        
        #endregion

        #region Constructor
        public ProducerList()
        {
            InitializeComponent();           
            presenter = new ProducerPresenter(this);
            CurrentProducer = new Producer();
            GridProducerDetails.DataContext = CurrentProducer;
            IEnumerable<WebCameraId> cameras = webCameraControl.GetVideoCaptureDevices();
            this.ComboBoxCameras.ItemsSource = cameras;
            if (cameras.Count() > 0)
                this.ComboBoxCameras.SelectedIndex = 0;
        }
        #endregion

        #region Private Methods
        private void ButtonDelete_Click(object sender, System.Windows.RoutedEventArgs e)
        {
            MessageBoxResult result = MessageBox.Show("Realmente deseas eliminar a este productor?", "Confirmación", MessageBoxButton.YesNo, MessageBoxImage.Question);
            if (result == MessageBoxResult.Yes)
            {
                presenter.DeleteProducer();
            }

        }

        private void ButtonReloadList_Click(object sender, RoutedEventArgs e)
        {
            presenter.ReloadProducerList();
        }
        private void ButtonAddProducer_Click(object sender, System.Windows.RoutedEventArgs e)
        {
            presenter.NewProducer();
        }

        private void TextBoxSearchProducers_TextChanged(object sender, TextChangedEventArgs e)
        {
            CollectionViewSource.GetDefaultView(ListBoxProducers.ItemsSource).Refresh();
        }
        private void UserControl_IsVisibleChanged(object sender, System.Windows.DependencyPropertyChangedEventArgs e)
        {
            if ((bool)e.NewValue == true && !listLoaded)
            {
                presenter.Token = Token;
                presenter.Initialize();             
                ComboBoxCivilStatus.ItemsSource = CivilStatus;
                ComboBoxRegime.ItemsSource = Regimes;
                ComboBoxState.ItemsSource = States;
                ComboBoxGender.ItemsSource = Genders;
                ComboBoxState.SelectedValue = 14;         //JALISCO
                ComboBoxRegime.SelectedIndex = 0;
                ComboBoxGender.SelectedIndex = 0;
                ComboBoxCivilStatus.SelectedIndex = 0;
                listLoaded = true;
            }
        }

        

        private ImageCodecInfo GetEncoder(ImageFormat format)
        {
            ImageCodecInfo[] codecs = ImageCodecInfo.GetImageDecoders();
            foreach (ImageCodecInfo codec in codecs)
            {
                if (codec.FormatID == format.Guid)
                {
                    return codec;
                }
            }
            return null;
        }

        private void ButtonGetImage_Click(object sender, System.Windows.RoutedEventArgs e)
        {
            if (!webCameraControl.IsCapturing)
            {
                if (ComboBoxCameras.SelectedItem == null)
                {
                    MessageBox.Show("No se seleccionó alguna cámara", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                webCameraControl.StartCapture((WebCameraId)ComboBoxCameras.SelectedItem);              
                TextBoxImageInstructions.Text = "Click para GUARDAR foto";
                ButtonCaptureImage.Visibility = System.Windows.Visibility.Hidden;
                ButtonGetImage.Visibility = System.Windows.Visibility.Visible;
            }
            else
            {
                TextBoxImageInstructions.Text = "Click para CAPTURAR foto";
                ButtonCaptureImage.Visibility = System.Windows.Visibility.Visible;
                ButtonGetImage.Visibility = System.Windows.Visibility.Hidden;                
                Bitmap bitmap = webCameraControl.GetCurrentImage();
                ImageCodecInfo jpgEncoder = GetEncoder(ImageFormat.Jpeg);
                System.Drawing.Imaging.Encoder myEncoder = System.Drawing.Imaging.Encoder.Quality;
                EncoderParameters myEncoderParameters = new EncoderParameters(1);
                EncoderParameter myEncoderParameter = new EncoderParameter(myEncoder, 50L);
                myEncoderParameters.Param[0] = myEncoderParameter;               
                using (var memoryStream = new MemoryStream())
                {
                    bitmap.Save(memoryStream,jpgEncoder, myEncoderParameters);                    
                    CurrentProducer.Photo = memoryStream.ToArray();
                }                    
                webCameraControl.StopCapture();
            }
        }

        private void ButtonSave_Click(object sender, System.Windows.RoutedEventArgs e)
        {
            presenter.SaveProducer();
        }
    

        private void ButtonPrintGaffete_Click(object sender, System.Windows.RoutedEventArgs e)
        {
            if (CurrentProducer.Photo == null)
            {
                MessageBox.Show("Capture la foto del productor primero. ", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                return;                
            }
            Gaffette_Preview preview = new Gaffette_Preview(CurrentProducer);
            preview.Show();

        }

        private void ListBoxProducers_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if(ListBoxProducers.SelectedItem != null)
            {
                presenter.UpdateCurrentProducer();
            }            
        }
        #endregion     
    }
}
