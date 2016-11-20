﻿using LasMargaritas.BL.Views;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using LasMargaritas.Models;
using LasMargaritas.BL.Presenters;

namespace LasMargaritas.UI.UserControls
{
    /// <summary>
    /// Interaction logic for WeightTicketList.xaml
    /// </summary>
    public partial class WeightTicketList : UserControl, IWeightTicketView
    {
        #region Private variables        
        private bool listLoaded;
        private WeightTicketPresenter presenter;
        private List<SelectableModel> _WeightTickets;
        #endregion

        #region Public properties
        public Token Token { get; set; }
        #endregion

        #region IWeightTicketView
        public List<SelectableModel> Producers { get; set; }
        public List<SelectableModel> WareHouses { get; set; }

        public List<SelectableModel> Products { get; set; }

        public List<SelectableModel> FilterCicles { get; set; }

        public List<SelectableModel> Cicles { get; set; }

        public List<SelectableModel> Ranchers { get; set; }

        public List<SelectableModel> Suppliers { get; set; }

        public List<SelectableModel> SalesCustomers { get; set; }
        public List<SelectableModel> WeightTickets { get; set; }

        public int SelectedId
        {
            get
            {
                if (ListBoxTickets.SelectedItem != null)
                {
                    return ((SelectableModel)ListBoxTickets.SelectedItem).Id;
                }
                return -1;
            }
            set
            {
                if (value <= 0)
                {

                    ListBoxTickets.SelectedValue = null;
                    ListBoxTickets.SelectedIndex = -1;
                }
                else
                {
                    foreach (var item in ListBoxTickets.Items)
                    {
                        if (((SelectableModel)item).Id == value)
                        {
                            ListBoxTickets.SelectedItem = item;
                            ListBoxTickets.ScrollIntoView(item);
                            break;
                        }
                    }
                }

            }
        }

        public WeightTicket CurrentWeightTicket { get; set; }
        
        
        public void HandleException(Exception ex, string method, Guid errorId)
        {
            
        }
        #endregion
        #region Constructors

        public WeightTicketList()
        {
            InitializeComponent();
            presenter = new WeightTicketPresenter(this);
            CurrentWeightTicket = new WeightTicket();            
            GridTicketsDetails.DataContext = CurrentWeightTicket;
        }
        #endregion

        #region Private methods
        
        private void btnNewTicket_Click(object sender, RoutedEventArgs e)
        {
            presenter.NewWeightTicket();
        }
        #endregion

        private void btnReloadTicket_Click(object sender, RoutedEventArgs e)
        {

        }

        private void UserControl_IsVisibleChanged(object sender, DependencyPropertyChangedEventArgs e)
        {
            if ((bool)e.NewValue == true && !listLoaded)
            {
                presenter.Token = Token;
                presenter.Initialize();
                this.ComboBoxTicketType.SelectedIndex = 0;
                ComboBoxCiclesFilter.ItemsSource = FilterCicles;
                ComboBoxCicles.ItemsSource = Cicles;
                ComboBoxProducer.ItemsSource = Producers;
                ComboBoxProducts.ItemsSource = Products;
                ComboBoxRancher.ItemsSource = Ranchers;
                ComboBoxSalesCustomer.ItemsSource = SalesCustomers;
                ComboBoxSupplier.ItemsSource = Suppliers;
                ComboboxWareHouse.ItemsSource = WareHouses; 
                listLoaded = true;
                CreateDummyTicket();
            }
        }
        private  void CreateDummyTicket()
        {
            WeightTicket weightTicket = CurrentWeightTicket;
            weightTicket.Amount = 10000;
            weightTicket.ApplyDrying = true;
            weightTicket.ApplyHumidity = true;
            weightTicket.ApplyImpurities = true;
            weightTicket.BrokenGrainDiscount = 10;
            weightTicket.CicleId = 1;
            weightTicket.CrashedGrainDiscount = 10;
            weightTicket.DamagedGrainDiscount = 10;
            weightTicket.Driver = "Driver";
            weightTicket.DryingDiscount = 10;
            weightTicket.EntranceDate = DateTime.Now;
            weightTicket.EntranceNetWeight = 1000;
            weightTicket.EntranceWeigher = "Weigher";
            weightTicket.EntranceWeightKg = 1500;
            weightTicket.ExitWeightKg = 1000;
            weightTicket.ExitDate = DateTime.Now;
            weightTicket.ExitNetWeight = 200;
            weightTicket.ExitWeigher = "Weigher";
            weightTicket.Folio = "Folio" + DateTime.Now.ToString("yyyyMMddHHmmssfff");
            weightTicket.Humidity = 10;
            weightTicket.HumidityDiscount = 10;
            weightTicket.Impurities = 10;
            weightTicket.ImpuritiesDiscount = 10;
            weightTicket.NetWeight = 400;
            weightTicket.Number = "Number" + DateTime.Now.ToString("yyyyMMddHHmmssfff");
            weightTicket.Paid = false;
            weightTicket.Plate = "Plate";
            weightTicket.Price = 10;
            weightTicket.ProducerId = 1;
            weightTicket.ProductId = 1;
            weightTicket.SmallGrainDiscount = 10;
            weightTicket.StoreTs = DateTime.Now;
            weightTicket.TotalDiscount = 50;
            weightTicket.TotalToPay = 100;
            weightTicket.UpdateTs = DateTime.Now;
            weightTicket.UserId = "35d360f3-c296-4113-ab34-9b91fe729c18";
            weightTicket.WarehouseId = 1;
            weightTicket.Freight = true;
            weightTicket.RaiseUpdateProperties();         
        }


        private void ComboBoxTicketType_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            string selectedValue = ((ComboBoxItem)ComboBoxTicketType.SelectedValue).Content.ToString();
            LabelProducer.Visibility = Visibility.Collapsed;
            ComboBoxProducer.Visibility = Visibility.Collapsed;
            ComboBoxProducer.SelectedIndex = -1;
            LabelRancher.Visibility = Visibility.Collapsed;
            ComboBoxRancher.Visibility = Visibility.Collapsed;
            ComboBoxRancher.SelectedIndex = -1;
            LabelSalesCustomer.Visibility = Visibility.Collapsed;
            ComboBoxSalesCustomer.Visibility = Visibility.Collapsed;
            ComboBoxSalesCustomer.SelectedIndex = -1;
            LabelSupplier.Visibility = Visibility.Collapsed;
            ComboBoxSupplier.Visibility = Visibility.Collapsed;
            ComboBoxSupplier.SelectedIndex = -1;
            GridCattle.Visibility = Visibility.Collapsed; 

            if (selectedValue == "Productor")
            {
                LabelProducer.Visibility = Visibility.Visible;
                ComboBoxProducer.Visibility = Visibility.Visible;
            }
            else if (selectedValue == "Ganadero")
            {
                LabelRancher.Visibility = Visibility.Visible;
                ComboBoxRancher.Visibility = Visibility.Visible;
                GridCattle.Visibility = Visibility.Visible;
            }
            else if (selectedValue == "Cliente de Venta")
            {
                LabelSalesCustomer.Visibility = Visibility.Visible;
                ComboBoxSalesCustomer.Visibility = Visibility.Visible;
            }
            else if (selectedValue == "Proveedor")
            {
                LabelSupplier.Visibility = Visibility.Visible;
                ComboBoxSupplier.Visibility = Visibility.Visible;
            }
        }

        private void btnSave_Click(object sender, RoutedEventArgs e)
        {
            presenter.SaveWeightTicket();
        }

        private void ButtonGetDate2_Click(object sender, RoutedEventArgs e)
        {
            presenter.SetExitDateToNow();
        }

        private void ButtonGetDate_Click(object sender, RoutedEventArgs e)
        {
            presenter.SetEntranceDateToNow();
        }
    }     
}