package examples;

import com.itextpdf.text.Chunk;
import com.itextpdf.text.Document;
import com.itextpdf.text.Element;
import com.itextpdf.text.Font;
import com.itextpdf.text.PageSize;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.pdf.BaseFont;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;

import java.io.FileOutputStream;
import java.text.SimpleDateFormat;
import java.util.Date;

public class CreatePdf {

    public static void main(String[] args) {
        try {
            String templatePath = "C:/Users/harshit.rai/Desktop/New folder/NewFile.pdf";
            Document document = new Document(PageSize.A4.rotate());
            PdfWriter writer = PdfWriter.getInstance(document, new FileOutputStream(templatePath));
            document.open();

            Font bold = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD);
            Font bold1 = new Font(Font.FontFamily.HELVETICA, 16, Font.BOLD);

            Date d = new Date();
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            String currentDateTime = dateFormat.format(d);

            document.add(new Paragraph("\n"));
            Paragraph wiNameDate = new Paragraph(
                    "WI Name : " + "WI----100001778" + "\n" + "Current Date : " + currentDateTime, bold);
            wiNameDate.setAlignment(Element.ALIGN_RIGHT);
            document.add(wiNameDate);
            document.add(Chunk.NEWLINE);

            // Load Arabic font
            BaseFont arabicBaseFont = BaseFont.createFont(
                    "C:/Users/harshit.rai/Desktop/New folder/Arial-Unicode-Regular.ttf",
                    BaseFont.IDENTITY_H, BaseFont.EMBEDDED);
            Font arabicFont = new Font(arabicBaseFont, 12);

            // Create a table with two columns
            PdfPTable table = new PdfPTable(2);
            table.setWidthPercentage(100); // Make table width 100%
            table.setWidths(new float[]{65, 35}); // Set column widths

            // Add initial row with English and Arabic text
            PdfPCell englishCell = new PdfPCell(new Paragraph("Personal Information:", bold1));
            englishCell.setHorizontalAlignment(Element.ALIGN_LEFT);
            englishCell.setVerticalAlignment(Element.ALIGN_MIDDLE);
            englishCell.setBorder(PdfPCell.NO_BORDER); // Remove borders
            table.addCell(englishCell);

            PdfPCell arabicCell = new PdfPCell(new Paragraph("مرحبًا، كيف حالك", arabicFont));
            arabicCell.setRunDirection(PdfWriter.RUN_DIRECTION_RTL);
            arabicCell.setHorizontalAlignment(Element.ALIGN_RIGHT);
            arabicCell.setVerticalAlignment(Element.ALIGN_MIDDLE);
            //arabicCell.setBorder(PdfPCell.NO_BORDER); // Remove borders
            table.addCell(arabicCell);

            // Add 10 additional rows with English and Arabic text
            
                PdfPCell englishCellRow = new PdfPCell(new Paragraph("This is a very long sentence which need to be converted into arabic text", bold));
                englishCellRow.setHorizontalAlignment(Element.ALIGN_LEFT);
                englishCellRow.setVerticalAlignment(Element.ALIGN_MIDDLE);
                englishCellRow.setBorder(PdfPCell.NO_BORDER); // Remove borders
                table.addCell(englishCellRow);

                PdfPCell arabicCellRow = new PdfPCell(new Paragraph("يجب ترجمة النص الطويل إلى اللغة العربية، دعونا نرى ما إذا كان هذا سينجح", arabicFont));
                arabicCellRow.setRunDirection(PdfWriter.RUN_DIRECTION_RTL);
                arabicCellRow.setHorizontalAlignment(Element.ALIGN_RIGHT);
                arabicCellRow.setVerticalAlignment(Element.ALIGN_MIDDLE);
                arabicCellRow.setBorder(PdfPCell.NO_BORDER); // Remove borders
                table.addCell(arabicCellRow);
            

            // Add the table to the document
            document.add(table);

            // Add a new line after the table
            

            // Add more content if needed
            Paragraph para = new Paragraph("Additional English Text:", bold1);
            para.setAlignment(Element.ALIGN_LEFT);
            document.add(para);
            document.add(new Paragraph("\n"));

            document.close();

            System.out.print("generated");

        } catch (Exception e) {
            System.out.print(e);
        }
    }
}
